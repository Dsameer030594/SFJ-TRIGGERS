public class LeadTriggerHandler {

    //Triger Scenario 2. 14: Whenever Lead is created with LeadSource as Web then give rating as cold otherwise hot.
    public static void changeRatingtoHot(List<Lead> leadList){
        
        for(Lead ld : leadList){
            if(ld.LeadSource == 'Web'){
                ld.Rating = 'Cold';
            } else{
                ld.Rating = 'Hot';
            }
        }
    }
    
    // 2.Prefix first name with Dr when new Lead is created or updated
    
    public static void prefixDrtoFirstName(List<Lead> leadList, Map<Id, Lead> leadOldMap){
 
        for(Lead ld : leadList){
            if(ld.FirstName != leadOldMap.get(ld.Id).FirstName && leadOldMap != null){
                ld.FirstName = 'Dr' + ld.FirstName; 
            }
        }
    }
    
    //6.  When lead is created or updated then check 
    // if the email of lead is already there in existing contacts. If email already exist then throw error.
    public static void DuplicateEmailsInLead(List<Lead> leadList, Map<Id, Lead> leadOldMap){
        
        Set<String> leadEmails = new Set<String>();
        Map<Id, String> existingContactsByEmail = new Map<Id, String>();
        
        for(Lead ld : leadList){
            if(ld.Email != null && ld.Email != leadOldMap.get(ld.Id).Email){
                leadEmails.add(ld.Email);
            }
        }
        // Query for existing Contacts with the same emails
        for(Contact con : [Select Id, AccountId, Email from Contact where Email IN: leadEmails]){
            existingContactsByEmail.put(con.Id, con.Email);
        }
        // Check for duplicate emails and throw error
        for(Lead ld : leadList){
            if(existingContactsByEmail.containsKey(ld.Email) && ld.Email != null){
                ld.addError('Lead email already exists in Contacts.');
            }
        }
        
       
    }
}