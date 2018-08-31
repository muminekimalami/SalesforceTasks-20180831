@isTest
public class OpportunityAndContactTest {
    
    @isTest static void testInsertOpps () {
        List<Opportunity> opps = new List<Opportunity>();
        Contact testC = new Contact(LastName = 'Test Contact', Business_Area_New__c = 'Finance'); 
        insert testC;
        
        for (Integer i = 0; i < 15; ++i) {
            opps.add(
                new Opportunity (Name = 'Test Opp ' + i, StageName = 'Prospecting', CloseDate = Date.today(), Business_Area_New__c = 'Finance')
            );
        }
        
        Test.startTest();
        insert opps;
        Test.stopTest();
        
        opps = [Select Main_Contact__c From Opportunity WHERE Business_Area_New__c = 'Finance'];
        for (Opportunity o : opps) {
            System.assertEquals(o.Main_Contact__c, testC.Id);
        }
    }
    
    @isTest static void testUpdateOpps () {
        Contact testC = new Contact(LastName = 'Test Contact', Business_Area_New__c = 'Finance');
        Contact testC2 = new Contact(LastName = 'Test Contact 2', Business_Area_New__c = 'Production');
        insert testC2;
        insert testC;
        List<Opportunity> opps = new List<Opportunity>();        
        for (Integer i = 0; i < 15; ++i) {
            opps.add(
                new Opportunity (Name = 'Test Opp ' + i, StageName = 'Prospecting', CloseDate = Date.today(), Business_Area_New__c = 'Finance')
            );
        }
        insert opps;
        
        for (Opportunity o : opps) {
            o.Business_Area_New__c = 'Production';
        }
        Test.startTest();
        update opps;
        Test.stopTest();
        opps = [Select Main_Contact__c From Opportunity WHERE Business_Area_New__c = 'Production'];
        for(Opportunity o : opps) {
            System.assertEquals(o.Main_Contact__c, testC2.Id);
        }
    }
    
    @isTest static void testCreateContacts () {
        List<Opportunity> opp = new List<Opportunity>();
        for (Integer i = 0; i < 15; ++i) {
            opp.add(
            	new Opportunity (Name = 'Test Opp ' + i, StageName = 'Prospecting', CloseDate = Date.today(), Business_Area_New__c = 'Finance')
            );
        }
        insert opp;
        Contact c = new Contact (LastName = 'Test Contact3', Business_Area_New__c = 'Finance');
        
        Test.startTest();
        insert c;
        Test.stopTest();
		
        opp = [SELECT Main_Contact__c FROM Opportunity WHERE Business_Area_New__c = 'Finance'];
        for (Opportunity o : opp) {
            System.assertEquals(c.Id, o.Main_Contact__c);
        }        
    }
    
    @isTest static void testUpdateContacts () {
        Contact c = new Contact (LastName = 'Test Contact3', Business_Area_New__c = 'Finance');       
        insert c;
        List<Opportunity> opp = new List<Opportunity>();
        for (Integer i = 0; i < 15; ++i) {
            opp.add(
            	new Opportunity (Name = 'Test Opp ' + i, StageName = 'Prospecting', CloseDate = Date.today(), Business_Area_New__c = 'Finance')
            );
        }
        insert opp;
        Contact c1 = new Contact (LastName = 'Test Contact4', Business_Area_New__c = 'Finance');
        insert c1;
        
        Test.startTest();
        c.Business_Area_New__c = 'Production';
        update c;
        test.stopTest();
        
        opp = [SELECT Id, Business_Area_New__c, Main_Contact__c FROM Opportunity];
        for (Opportunity o : opp) {
            System.assertEquals(c1.Id, o.Main_Contact__c);
        }
    }
    
    @isTest static void deleteContacts () {
        Contact c = new Contact (LastName = 'Test Contact3', Business_Area_New__c = 'Finance');       
        insert c;
        List<Opportunity> opp = new List<Opportunity>();
        for (Integer i = 0; i < 15; ++i) {
            opp.add(
            	new Opportunity (Name = 'Test Opp ' + i, StageName = 'Prospecting', CloseDate = Date.today(), Business_Area_New__c = 'Finance')
            );
        }
        insert opp;
        Contact c1 = new Contact (LastName = 'Test Contact4', Business_Area_New__c = 'Finance');
        insert c1;
        
        Test.startTest();
        delete c;
        test.stopTest();
        
        opp = [SELECT Id, Business_Area_New__c, Main_Contact__c FROM Opportunity];
        for (Opportunity o : opp) {
            System.assertEquals(c1.Id, o.Main_Contact__c);
        }
    }
}