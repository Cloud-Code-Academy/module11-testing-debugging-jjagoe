@isTest
public with sharing class LeadTriggerHandlerTest {

 
    @TestSetup
    static void makeTestData() {
        Account acct = new Account(Name='Test Account');
        insert acct;

        List<Contact> contacts = new List<Contact>{new Contact(FirstName='John1', LastName ='Smith1', Email='smith1@Test.com', AccountId = acct.Id),
                                                   new Contact(FirstName='John2', LastName ='Smith2', Email='smith2@Test.com', AccountId = acct.Id),
                                                   new Contact(FirstName='John3', LastName ='Smith3', Email='smith3@Test.com', AccountId = acct.Id),
                                                   new Contact(FirstName='John4', LastName ='Smith4', Email='smith4@Test.com', AccountId = acct.Id)
                                                  };
        insert contacts;
        List<Lead> leads = new List<Lead>{new Lead(FirstName='Jane1', LastName='Doe1', Company='Test Company', Status='Open', Title='vp', Email = 'Doe1@Test.com', Industry='Technology' ),
                                          new Lead(FirstName='Jane2', LastName='Doe2', Company='Test Company', Status='Open', Title='v.p', Email = 'Doe2@Test.com' ),
                                          new Lead(FirstName='Jane3', LastName='Doe3', Company='Test Company', Status='Open', Title='v.p.', Email = 'Doe3@Test.com' ),
                                          new Lead(FirstName='Jane4', LastName='Doe4', Company='Test Company', Status='Open', Title='vice president', Email = 'Doe4@Test.com', Industry='Technology' ),
                                          new Lead(FirstName='Jane5', LastName='Doe5', Company='Test Company', Status='Open', Title='mgr', Email = 'Doe5@Test.com' ),
                                          new Lead(FirstName='Jane6', LastName='Doe6', Company='Test Company', Status='Open', Title='manager', Email = 'Doe6@Test.com' ),
                                          new Lead(FirstName='Jane7', LastName='Doe7', Company='Test Company', Status='Open', Title='head of department' , Email = 'Doe7@Test.com'),
                                          new Lead(FirstName='Jane8', LastName='Doe8', Company='Test Company', Status='Open', Title='exec', Email = 'Doe8@Test.com' ),
                                          new Lead(FirstName='Jane9', LastName='Doe9', Company='Test Company', Status='Open', Title='chief' , Email = 'Doe9@Test.com', Phone='+7161234567'),
                                          new Lead(FirstName='Jane10', LastName='Doe10', Company='Test Company', Status='Open', Title='head' , Email = 'Doe10@Test.com'),
                                          new Lead(FirstName='Jane11', LastName='Doe11', Company='Test Company', Status='Open', Title='assistant' , Email = 'Doe11@Test.com'),
                                          new Lead(FirstName='Jane12', LastName='Doe12', Company='Test Company', Status='Open', Title='deputy' , Email = 'Doe12@Test.com'),
                                          new Lead(FirstName='Jane13', LastName='Doe13', Company='Test Company', Status='Open', Title='jr', Email = 'Doe13@Test.com', Phone='+7169876543' )
                                            };

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Test.startTest();
        Database.insert(leads, dml);
        Test.stopTest();
    }

    @IsTest
    static void testHandleTitleNormalization() {
        List<Lead> testLeads = [SELECT Id, Company, Title from Lead where Company = 'Test Company'];
        System.assertEquals(13,testLeads.size());
        System.assertEquals('Manager', testLeads.get(5).Title, 'Title is not set properly');
        System.assertEquals('v.p', testLeads.get(1).Title, 'Expected title as v.p but found normalized');
    }

    @isTest
    static void testHandleAutoLeadScoring() {
        List<Lead> scoreUpdates = new List<Lead>([SELECT Id, FirstName, LastName, Lead_Score__c, LeadSource, Email, Phone, Industry
                                                    FROM Lead
                                                    ORDER BY Lead_Score__c DESC]);
        for (Lead ld : scoreUpdates) {
            if (ld.Industry=='Technology' && ld.Phone != null && ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(18, ld.Lead_Score__c, 'Lead Score should have been 18');
            } else if(ld.Industry=='Technology' && ld.Phone != null) {
                System.assertEquals(15, ld.Lead_Score__c, 'Lead Score should have been 15');
            } else if(ld.Industry=='Technology' && ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(13, ld.Lead_Score__c, 'Lead Score should have been 13');
            } else if (ld.Industry=='Technology') {
                System.assertEquals(10, ld.Lead_Score__c, 'Lead Score should have been 10');
            } else if (ld.Phone != null && ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(8, ld.Lead_Score__c, 'Lead Score should have been 8');
            } else if (ld.Phone != null) {
                System.assertEquals(5, ld.Lead_Score__c, 'Lead Score should have been 5');
            } else if (ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(3, ld.Lead_Score__c, 'Lead Score should have been 3');
            } else {
                System.assertEquals(0, ld.Lead_Score__c, 'Lead Score should have been 0');
            }
        }

        for (Lead ld : scoreUpdates) {
            if (ld.Phone != null) {
                ld.Phone = null;
            }
            if (ld.Email != null) {
                ld.Email = null;
            }
        }
        Test.startTest();
        Database.update(scoreUpdates, AccessLevel.SYSTEM_MODE);
        Test.stopTest();
        List<Lead> scoresRoundTwo = new List<Lead>([SELECT Id, FirstName, LastName, Lead_Score__c, LeadSource, Email, Phone, Industry
                                                    FROM Lead
                                                    ORDER BY Lead_Score__c DESC]);
        for (Lead ld : scoresRoundTwo) {
            if (ld.Industry=='Technology' && ld.Phone != null && ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(18, ld.Lead_Score__c, 'Lead Score should have been 18');
            } else if(ld.Industry=='Technology' && ld.Phone != null) {
                System.assertEquals(15, ld.Lead_Score__c, 'Lead Score should have been 15');
            } else if(ld.Industry=='Technology' && ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(13, ld.Lead_Score__c, 'Lead Score should have been 13');
            } else if (ld.Industry=='Technology') {
                System.assertEquals(10, ld.Lead_Score__c, 'Lead Score should have been 10');
            } else if (ld.Phone != null && ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(8, ld.Lead_Score__c, 'Lead Score should have been 8');
            } else if (ld.Phone != null) {
                System.assertEquals(5, ld.Lead_Score__c, 'Lead Score should have been 5');
            } else if (ld.LeadSource == 'Web' && ld.Email != null) {
                System.assertEquals(3, ld.Lead_Score__c, 'Lead Score should have been 3');
            } else {
                System.assertEquals(0, ld.Lead_Score__c, 'Lead Score should have been 0');
            }
        }
    }
    

    @isTest
    static void testHandleLeadAutoConvert(){
        List<Contact> testContacts = new List<Contact>();
        List<Lead> testLeads = new List<Lead>();
        Account testAccount1 = new Account(Name = 'Test Account');

        insert testAccount1;

        Contact testContact1 = new Contact(LastName = 'Test Contact', Email = 'test@test.com', AccountId = testAccount1.Id);
        Contact testContact2 = new Contact(LastName = 'Test Contact', Email = 'test2@test.com', AccountId = testAccount1.Id);
        Contact testContact3 = new Contact(LastName = 'Test Contact', Email = 'test2@test.com', AccountId = testAccount1.Id);
        Lead testLead1 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Email = 'test@test.com');
        Lead testLead2 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Email = 'test2@test.com');
        Lead testLead3 = new Lead(LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted', Email = 'test3@test.com');

        testContacts.add(testContact1);
        testContacts.add(testContact2);
        testContacts.add(testContact3);
        testLeads.add(testLead1);
        testLeads.add(testLead2);
        testLeads.add(testLead3);

        insert testContacts;

        Test.startTest();
        insert testLeads;
        Test.stopTest();

        List<Lead> convertedLeads = [SELECT Id, IsConverted, Email FROM Lead WHERE Id = :testLeads];
        System.debug('convertedLeads: '+convertedLeads);

        for (Lead testLead : convertedLeads) {
            if (testLead.Email == 'test@test.com') {
                System.assertEquals(true, testLead.IsConverted, 'The lead should be converted.');
            }
            if (testLead.Email == 'test2@test.com') {
                System.assertEquals(false, testLead.IsConverted, 'The lead should not be converted.');
            }
            if (testLead.Email == 'test3@test.com') {
                System.assertEquals(false, testLead.IsConverted, 'The lead should not be converted.');
            }
        }
    }
}