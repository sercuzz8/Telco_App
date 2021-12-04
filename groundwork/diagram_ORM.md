# ORM 

1. Relationship “creates” 
    - User -> CustomerOrder @OneToMany is necessary because we need a collection of rejected orders. 
    - CustomerOrder -> User @ManyToOne is not necessary because not requested by the specification (we always visualize orders of single users). 
    - CustomerOrder is the owner of the relationship. 
    - We choose to use a NamedQuery to create the list of rejected orders because of the specific request, so we don't need to map the @OneToMany relationship in the class User. 


 

1. Relationship “has” with ServiceActivationSchedule 
    - User -> ServiceActivationSchedule @OneToMany. 
    - ServiceActivationSchedule -> User @ManyToOne. 
    - ServiceActivationSchedule is the owner of the relationship. 
    - Both directions are not actually needed in the specifications, but we decided to map them anyway. 
    - FetchType is LAZY because we don’t need information about Schedules in the application when the user login.  

 

1. Relationship “has” with AuditingTable 
    - User -> AuditingTable @OneToOne. 
    - AuditingTable -> User @OneToOne. 
    - AuditingTable is the owner of the relationship. 
    - Both directions are not actually needed in the specifications, but we decided to map them anyway. 
    - FetchType is LAZY because we don’t need information about Schedules in the application when the user login.  

 

1. Relationship “has” CostumerOrder-ServicePackage 
    - CostumerOrder -> Service Package @ManyToOne is necessary because the order info needs to display the service package chosen 
    - ServicePackage -> CostumerOrder @OneToMany is necessary because an employee has to see the number of order per Service Package, we might create a Named Query for this, avoiding the use of the @ToMany expression. 
    - CostumerOrder is the owner of the relationship. 


1. Relationship “include” 
    - CostumerOrder -> OptionalProduct @ManyToMany is necessary because we need to map the list of optional products included in one order 
    - OptionalProduct -> CostumerOrder @ManyToMany is necessary in the employee applications to generate the number of orders in which an optional product is included 
    - We assume the CostumerOrder as the owner of the relationship.     


1. Reltionship “has” CostumerOrder-ValidityPeriod 
    - CostumerOrder -> ValidityPeriod @ManyToOne is necessary to map the validity period chosen in the order and display it. 
    - ValidityPeriod -> CostumerOrder @OneToMany is necessary in the employee application to map the total purchases per validity period. 
    - CostumerOrder is the owner of the relationship. 
    - We set a FetchType LAZY because we don’t actually need to load all orders when referencing to a specific validity period. 


1. Relationship "offersProduct" ServicePackage-OptionalProduct
    - ServicePackage -> OptionalProduct @ManyToMany is necessary to map all the optional products offered in the service package. FetchType.EAGER because we need the information when choosing the plan (we also expect few products for every package)
    - OptionalProduct -> ServicePackage @ManyToMany mapped for simplicity as we are not tasked to retrieve a package going from a product
    - We assume ServicePackage as the owner of the relationship.

 
1. Relationship "includesServices" ServicePackage-Service
    - ServicePackage -> Service @ManyToMany is necessary to map all the services included in the service package. FetchType.EAGER because we need the information when choosing the plan; even tough there can be many different choices services in one single package, we need to have all them lined out when choosing (the numbers are also expected to be restricted)
    - Service -> ServicePackage @ManyToMany mapped for simplicity as we are not tasked to retrieve a package going from a service
    - We assume ServicePackage as the owner of the relationship.
