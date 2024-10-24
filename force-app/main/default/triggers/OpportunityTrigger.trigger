trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, after delete, after undelete) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            OpportunityTriggerHandler.setCloseDateandType(Trigger.new, null);
            OpportunityTriggerHandler.updateAccountRatingToHot(Trigger.new, null);
        } else if(Trigger.isAfter){
            OpportunityTriggerHandler.createRelatedTask(Trigger.new, null);
            OpportunityTriggerHandler.rolupNoOfOppOnAccount(Trigger.new);
            OpportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.new, null);
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            OpportunityTriggerHandler.setCloseDateandType(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.updateAccountRatingToHot(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isAfter){
            OpportunityTriggerHandler.updaterelatedAccNadConField(Trigger.new, Trigger.oldMap);
            OpportunityTriggerHandler.createRelatedTask(Trigger.new, Trigger.oldMap);
            mixedDmlOnOpportunity.createRelatedTaskandAssignPermissionSet(Trigger.new, Trigger.oldMap);
             OpportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.isDelete){
        if(Trigger.isAfter){
             OpportunityTriggerHandler.rolupNoOfOppOnAccount(Trigger.old);
             OpportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.old, null);
        }
}
    if(Trigger.isUnDelete){
        if(Trigger.isAfter){
             OpportunityTriggerHandler.rolupNoOfOppOnAccount(Trigger.new);
             OpportunityTriggerHandler.rollupHighValueOppONAccount(Trigger.new, null);
        }
}
}