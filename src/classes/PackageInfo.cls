public with sharing class PackageInfo{

public Package__c packageinfo;

    public PackageInfo(){
       packageinfo = [SELECT Name,City__c,Cost__c,No_Of_Days__c from Package__c WHERE Name=: ApexPages.currentPage().getParameters().get('id')];
      }
    
    public Package__c getPackageinfo(){
    return packageinfo;
    }
    }