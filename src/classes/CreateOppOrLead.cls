global class CreateOppOrLead implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Access_Level__c, Account_Access_Level__c, Case_Access_Level__c, ' +
            'Contact_Access_Level__c, Customer_Id__c, Member_Id__c, ' +
            'Name, Number_of_Days__c, Opportunity_Lead_Owner__c, ' + 
            'Status__c, Team_Role__c, Type__c' +
            'FROM Analitical_Staging_Object__c WHERE Status__c = \'New\''
        );
    }

    global void execute(Database.BatchableContext bc, List<Analitical_Staging_Object__c> scope) {
        
        List<Opportunity> opps = new List <Opportunity>();
        List<OpportunityTeamMember> teamMembers = new List<OpportunityTeamMember>();
        List<Task> tasks = new List<Task>();
        List<Lead> leads = new List<Lead>();


        Set<Id> accountsId = new Set<Id>();
        Set<String> emails = new Set<String>();
        for (Analitical_Staging_Object__c a : scope) {
            emails.add(a.Opportunity_Lead_Owner__c);
            accountsId.add(a.Customer_Id__c);
        }

        List<User> users = [SELECT Id, Email FROM User WHERE Email IN :emails];
        Map<String, Id> email2UserId = new Map<String, Id>();
        for (User u : users) {
            if (!email2UserId.containsKey(u.Email)) {
                email2UserId.put(u.Email, u.Id);
            }
        }

        List<Account> accounts = [SELECT Id, OwnerId FROM Account WHERE Id IN :accountsId];
        Map<Id, Id> acc2AccOwnerId = new Map<Id, Id>();
        for (Account a : accounts) {
            acc2AccOwnerId.put(a.Id, a.OwnerId);
        }

        for (Analitical_Staging_Object__c aso : scope) {
            if (aso.Type__c == '01') {
                Id oppOwner;
                
                if (email2UserId.containsKey(aso.Opportunity_Lead_Owner__c)) {
                    oppOwner = email2UserId.get(aso.Opportunity_Lead_Owner__c);
                }else {
                    oppOwner = acc2AccOwnerId.get(aso.Customer_Id__c);
                }

                Opportunity opportunity = new Opportunity( Name = aso.Name, AccountId = aso.Customer_Id__c, OwnerId = oppOwner, Business_Area_New__c = 'Production');
                OpportunityTeamMember teamMember = new OpportunityTeamMember ( UserId = aso.Member_Id__c, TeamMemberRole = aso.Team_Role__c,
                    Account_Access_Level__c = aso.Access_Level__c, Case_Access_Level__c = aso.Case_Access_Level__c, Contact_Access_Level__c = aso.Contact_Access_Level__c, OpportunityId = opportunity.Id
                );
                Task task = new Task ( OwnerId = opportunity.OwnerId, ActivityDate = Date.today().addDays((Integer)aso.Number_of_Days__c), Type = 'AnalyticalOppTask');
                opps.add(opportunity);
                teamMembers.add(teamMember);
                tasks.add(task);
                aso.Status__c = 'OK';
            }else if (aso.Type__c == '02') {

            }else {
                aso.Status__c = 'NOK';
            }
        }

        if (opps.size() > 0) {
            insert opps;
        }
        if (teamMembers.size() > 0) {
            insert teamMembers;
        }
        if (tasks.size() > 0) {
            insert tasks;
        }
    }

    global void finish(Database.BatchableContext bc) {
        
    }    
}  