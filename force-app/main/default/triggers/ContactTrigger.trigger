trigger ContactTrigger on Contact (before insert, after insert, after update, after delete, after undelete) {
    
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            ContactTriggerHandler.setConPhonetoAccPhone(Trigger.new);     
        } else if(Trigger.isAfter){
            ContactTriggerHandler.countContactsRolluponAcc(Trigger.new, null);     
        }
    }
    
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            ContactTriggerHandler.updateOppAndAccountPhone(Trigger.new, Trigger.oldMap); 
        }
    }
    
    if(Trigger.isDelete){
        if(Trigger.isAfter){
            ContactTriggerHandler.countContactsRolluponAcc(Trigger.old, null);
        }
    }
    if(Trigger.isUndelete){
        if(Trigger.isAfter){
            ContactTriggerHandler.countContactsRolluponAcc(Trigger.new, null);
        }
    }
}