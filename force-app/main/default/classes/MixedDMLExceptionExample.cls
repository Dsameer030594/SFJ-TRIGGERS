public class MixedDMLExceptionExample {
    @future
    public static void mainMethod(){
        // Setup Object :- User, Profile, Groups, Permission Sets
        // Non-Setup Objects :- All Standard and Custom Objects;
        // Whenever you want to create setup and non setup object simultaneously 
        // at a time in single transction. you will receive mixed DML Exception
        
        Account acc = new Account();
        acc.Name = 'Sameera';
        insert acc;
        Method2();
    }
         public static void Method2(){
        //Get Profile Id
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        //Add User Information
        User objUser = new User();
        objUser.FirstName='Sameer';
        objUser.LastName = 'Dar';
        objUser.Alias = 'sameeDaro';
        objUser.Email = 'itzbiswajeet@gmail.com';
        objUser.Username = 'sameeDaro123@gmail.com';
        objUser.ProfileId = objProfile.id;
        objUser.TimeZoneSidKey = 'GMT';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LocaleSidKey = 'en_US';
        //Insert User
        Insert objUser;
         }
    }