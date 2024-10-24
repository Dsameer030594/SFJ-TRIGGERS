public class mixedDmlOnOpportunity {
    
    public static void createRelatedTaskandAssignPermissionSet(List<Opportunity> oppList, Map<Id, Opportunity> oppOldMap){
        List<Task> tkList = new List<Task>();
        Set<Id> userIds = new Set<Id>();
        
        for(Opportunity opp : oppList){
            if(opp.StageName == 'Closed Won' && opp.StageName != oppOldMap.get(opp.Id).StageName){
                Task tk = new Task();
                tk.Subject = 'Follow up Task';
                tk.Status = 'In Progress';
                tk.Priority = 'Normal';
                tk.OwnerId = opp.OwnerId;
                tk.WhatId = opp.Id;
                tkList.add(tk);
                
                // Collect the user ID for permission set assignment
                userIds.add(opp.OwnerId);
            }  
        }
        
        // Insert tasks in the same transaction
        if (!tkList.isEmpty()) {
            insert tkList;
        }
        
        // Call the @future method to assign permission set
        if (!userIds.isEmpty()) {
            assignPermissionSet(userIds);
        }
    }

    @future
    public static void assignPermissionSet(Set<Id> userIds){
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Experience Profile Manager' LIMIT 1];
        
        for(Id userId : userIds){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userId;
            psa.PermissionSetId = ps.Id;
            permissionSetAssignmentList.add(psa);
        }
        
        if (!permissionSetAssignmentList.isEmpty()) {
            insert permissionSetAssignmentList;
        }
    }  
}