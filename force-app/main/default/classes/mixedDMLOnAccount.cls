public class mixedDMLOnAccount {

    public static void createAccount() {
        Account acc = new Account();
        acc.Name = 'abc';
        insert acc;
        
        // Call future method to insert User
        insertUserWithRole();
    }
    
    @future
    public static void insertUserWithRole() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];   
        
        User u = new User();
        u.ProfileId = p.Id;
        u.FirstName = 'Ram';
        u.LastName = 'Kovind';
        u.Email = 'noreply@example.com';
        u.Username = 'anotherreply@example.com';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.Alias = 'integel';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        
        insert u;    
    }
}