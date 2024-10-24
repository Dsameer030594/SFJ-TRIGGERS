trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete) {

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            AccountTriggerHandler.preventDuplicationOfAccountName(Trigger.new, null);
            AccountTriggerHandler.assignOwnerAsSmriti(Trigger.new);
        } else if(Trigger.isAfter){
            AccountTriggerHandler.createAssociatedContact(Trigger.new);
            AccountTriggerHandler.createAssoContactWithLNamePhoneSame(Trigger.new);
            AccountTriggerHandler.createContactAccodingToNumberOfLocation(Trigger.new, null);
            AccountTriggerHandler.updateContactNametoSmriti(Trigger.new);
            AccountTriggerHandler.updateIndividualBanalnce(Trigger.new, null);
            mixedDMLOnAccount.createAccount();
        }
    }
    
    if(Trigger.isupdate){
        if(Trigger.isBefore){
            AccountTriggerHandler.preventDuplicationOfAccountName(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateNameFieldOfAccountRecord(Trigger.new, Trigger.oldMap);
        }else if(Trigger.isAfter){
            AccountTriggerHandler.updateCityFieldOfAccount(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.updateIndividualBanalnce(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.changeRelatedConName(Trigger.new, Trigger.oldMap);
            AccountTriggerHandler.sendEmailToOwner(Trigger.new, Trigger.oldMap); 
        }
    }
    
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            AccountTriggerHandler.peventDeletionOfAcc(Trigger.old);
            AccountTriggerHandler.prevetDeleteOfAccountOtherThanAdmin(Trigger.old);
           AccountTriggerHandler.preventDelwithOppAmount(Trigger.old);
            AccountTriggerHandler.preventDuplicationOfAccount(Trigger.old);
        }
    }
}