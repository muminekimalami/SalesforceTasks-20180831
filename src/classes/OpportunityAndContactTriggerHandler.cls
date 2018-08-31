public with sharing class OpportunityAndContactTriggerHandler {
    
    public void beforeInsertOpps (List<Opportunity> opps) {       
        updateBusinessArea(opps, findNeededContacts(opps));
    }
    
    public void beforeUpdateOpps (List<Opportunity> beforeUpd, List<Opportunity> afterUpd, Map<Id, Opportunity> id2Opp) {
        List<Opportunity> toBeUpdated = new List<Opportunity>();
        
        for (Opportunity op : beforeUpd) {
            if (op.Business_Area_New__c != null && op.Business_Area_New__c != id2Opp.get(op.Id).Business_Area_New__c) {
                toBeUpdated.add(id2Opp.get(op.Id));
            }
        }        
        updateBusinessArea(toBeUpdated, findNeededContacts(toBeUpdated));
    }
    
    public void beforeUpdateContacts (List<Contact> beforeUpd, Map<Id, Contact> id2Cont) {
        List<Contact> contactsChanged = new List<Contact>();
        Set<String> businessAreas = new Set<String>();
        for (Contact c : beforeUpd) {
            if (c.Business_Area_New__c != id2Cont.get(c.Id).Business_Area_New__c) {
                contactsChanged.add(c);
            	businessAreas.add(c.Business_Area_New__c);    
            }
        }
        List<Contact> contacts = [SELECT Id, Business_Area_New__c FROM Contact WHERE Business_Area_New__c IN :businessAreas];
        Map<String, Id> bisArea2ContId = new Map<String, Id>();
        for (Contact c : contacts) {
            if (!bisArea2ContId.containsKey(c.Business_Area_New__c)) {
                System.debug(c.Id + ' ' + c.Business_Area_New__c);
                bisArea2ContId.put(c.Business_Area_New__c, c.Id);
            }
        }
        List<Opportunity> opps2Upd = [SELECT Id, Business_Area_New__c, Main_Contact__c From Opportunity WHERE Main_Contact__c in :contactsChanged];
        updateBusinessArea(opps2Upd, bisArea2ContId);
        update opps2Upd;
    }
    
    public void beforeInsertContact (List<Contact> contacts) {
        Map<String, Id> bAr2Cont = new Map<String, Id>();
        for (Contact c : contacts) {
            if (!bAr2Cont.containsKey(c.Business_Area_New__c)) {
                bAr2Cont.put(c.Business_Area_New__c, c.Id);
            }
        }
        Set<String> businessAreas = bAr2Cont.keySet();
        
        List<Opportunity> opps = [SELECT Business_Area_New__c, Main_Contact__c FROM Opportunity WHERE Business_Area_New__c in :businessAreas AND Main_Contact__c = NULL];
        updateBusinessArea(opps, bAr2Cont);
        update opps;
    }
    
    public void beforeDeleteContacts (List<Contact> deletedContacts) {
        List<Opportunity> opps2Upd = [SELECT Id, Business_Area_New__c, Main_Contact__c From Opportunity WHERE Main_Contact__c in :deletedContacts];
        List<Id> contsId = new List<Id>();
        for (Contact c : deletedContacts) {
            contsId.add(c.Id);
        }
        
        Set<String> businessAreas = new Set<String>();
        for (Opportunity o : opps2Upd) {
            businessAreas.add(o.Business_Area_New__c);
        }
        List<Contact> contacts = [SELECT Id, Business_Area_New__c FROM Contact WHERE Business_Area_New__c IN :businessAreas AND Id NOT IN :contsId];
        Map<String, Id> buiArea2ContId = new Map<String, Id>();
        for (Contact c : contacts) {
            if (!buiArea2ContId.containsKey(c.Business_Area_New__c)) {
                buiArea2ContId.put(c.Business_Area_New__c, c.Id);
            }
        }
        
        updateBusinessArea(opps2Upd, buiArea2ContId);
        update opps2Upd;
    }
    
    public void updateBusinessArea (List<Opportunity> opps, Map<String, Id> BisArea2ContId) {
        for (Opportunity o : opps) {        
            if (BisArea2ContId.containsKey(o.Business_Area_New__c)) {                   
                o.Main_Contact__c = BisArea2ContId.get(o.Business_Area_New__c);
            }
        }      
    }
    
    public Map<String, Id> findNeededContacts (List<Opportunity> opps) {
        Set<String> businessAreas = new Set<String>();
        for (Opportunity o : opps) {
            businessAreas.add(o.Business_Area_New__c);
        }
        List<Contact> contacts = [SELECT Id, Business_Area_New__c FROM Contact WHERE Business_Area_New__c IN :businessAreas];
        Map<String, Id> buiArea2ContId = new Map<String, Id>();
        for (Contact c : contacts) {
            if (!buiArea2ContId.containsKey(c.Business_Area_New__c)) {
                buiArea2ContId.put(c.Business_Area_New__c, c.Id);
            }
        }
        return buiArea2ContId;
    }
}