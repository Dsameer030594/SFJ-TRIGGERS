trigger LeadTrigger on Lead (before insert, before update) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            LeadTriggerHandler.changeRatingtoHot(Trigger.new);
            LeadTriggerHandler.prefixDrtoFirstName(Trigger.new, null);
            LeadTriggerHandler.DuplicateEmailsInLead(Trigger.new, null);
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            LeadTriggerHandler.prefixDrtoFirstName(Trigger.new, Trigger.oldMap);
            LeadTriggerHandler.DuplicateEmailsInLead(Trigger.new, Trigger.oldMap);
        }
    }
}