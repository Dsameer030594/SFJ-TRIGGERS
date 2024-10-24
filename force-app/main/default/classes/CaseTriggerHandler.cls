public class CaseTriggerHandler {

    // Trigger Scenario 1. 13 a. :  Whenever a case is created with origin as email then set status as new and Priority as Medium.
    //  and when origin is web then set status as new and Priority as Low and when origin is phone then set status as Working and Priority as High
    
    public static void SetStatusAndPriority(List<Case> caseList){
        
        for(Case cs : caseList){
            if(cs.Origin == 'Email'){
                cs.Status = 'New';
                cs.Priority = 'Medium';
            } else if(cs.Origin == 'Web'){
                cs.Status = 'New';
                cs.Priority = 'Low';
            } else if(cs.Origin == 'Phone'){
                cs.Status = 'Working';
                cs.Priority = 'High';
            }
        }
    }
}