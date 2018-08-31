trigger AssignMainContact on Opportunity (before insert, before update) {
    
    OpportunityAndContactTriggerHandler handler = new OpportunityAndContactTriggerHandler();
    
    if (Trigger.isInsert) {
        handler.beforeInsertOpps(Trigger.new);
    } else {
        handler.beforeUpdateOpps(Trigger.old, Trigger.new, Trigger.newMap);
    }   
}