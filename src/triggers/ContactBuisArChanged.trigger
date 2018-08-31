trigger ContactBuisArChanged on Contact (after update, after insert, before delete) {
   
	OpportunityAndContactTriggerHandler handler = new OpportunityAndContactTriggerHandler();
    if (Trigger.isUpdate) {
    	handler.beforeUpdateContacts (Trigger.old, Trigger.newMap);    
    }else if (Trigger.isInsert) {
        handler.beforeInsertContact(Trigger.new);
    }else {
        handler.beforeDeleteContacts(Trigger.old);
    }
    
}