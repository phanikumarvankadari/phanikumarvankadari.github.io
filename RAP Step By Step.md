## ABAP Annotation Documentation

```link-bookmark
url:https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/abencds_annotations_ktd_docu.html
title:ABAP CDS - SAP Annotation Documentation | ABAP Keyword Documentation
description:
coverImg:
logo:ABAPIcon.ico
```

#### ABAP Annotations
- [AbapCatalog](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_ABAPCATALOG_A.html)
- [AccessControl](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_ACCESSCONTROL_A.html)
- [Aggregation](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_AGGREGATION_A.html)
- [API](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_API_A.html)
- [ClientHandling](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_CLIENTHANDLING_A.html)
- [EndUserText](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_ENDUSERTEXT_A.html)
- [Environment](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_ENVIRONMENT_A.html)
- [MappingRole](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_MAPPINGROLE_A.html)
- [Metadata](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_METADATA_A.html)
- [ObjectModel](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_OBJECTMODEL_A.html)
- [Semantics](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_SEMANTICS_A.html)
## Reference tutorial


```link-bookmark
url:https://github.com/miltonchandradas/rapdemo/tree/master
title:GitHub - miltonchandradas/rapdemo: ABAP RESTful Programming Model Demo
description:ABAP RESTful Programming Model Demo. Contribute to miltonchandradas/rapdemo development by creating an account on GitHub.
coverImg:https://opengraph.githubassets.com/bae56d805acef8331089dca5b9f1c2c2747080b7de2d00411149494889417559/miltonchandradas/rapdemo
logo:https://github.com/fluidicon.png
```

## Step1 - Create Table

Create package and Table


```
@EndUserText.label : 'UX demo table'
@AbapCatalog.enhancementCategory : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table zrap_uxteam_5551 {
  key client            : mandt not null;
  key id                : sysuuid_x16 not null;
  firstname             : abap.char(100);
  lastname              : abap.char(100);
  age                   : abap.numc(4);
  role                  : abap.char(100);
  salary                : abap.numc(4);
  active                : abap_boolean;
  last_changed_at       : timestampl;
  local_last_changed_at : timestampl;

}
```

 
- Here we only make tables fields
- in this example we have used managed fields client, last changed at, local last change at
## Step2   - Create Interface View

```
@AbapCatalog.sqlViewName: 'ZZI_UXTEAM_5551'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for UX demo'
define root view ZI_UXTEAM_5551
  as select from zrap_uxteam_5551
{

  key id                    as Id,
      firstname             as Firstname,
      lastname              as Lastname,
      age                   as Age,
      role                  as Role,
      salary                as Salary,
      active                as Active,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt

}
```

-   this will also serves as a root view. Here we define semantic attributes. Semantic attributes means system managed attributes like last changed at, local last changed at
-  documentation and examples : 
```link-bookmark
url:https://help.sap.com/doc/saphelp_nw75/7.5.5/en-US/fb/cd3a59a94148f6adad80b9c97304ff/content.htm?no_cache=true
title:Semantics Annotations
description:Used by the core engines for data processing, analytics, and data consumption
coverImg:../../DITAgraphics/locate.gif
logo:
```

## Step3 - Create Consumption View

```
@EndUserText.label: 'UXTeam Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity ZC_UXTEAM_5551
  as projection on ZI_UXTEAM_5551 as UXTeam
{
    @EndUserText.label: 'Id'
  key Id,
  @EndUserText.label: 'First Name'
      @Search.defaultSearchElement: true
      Firstname,
      @EndUserText.label: 'Last Name'
      @Search.defaultSearchElement: true
      Lastname,
      @EndUserText.label: 'Age'
      Age,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Role'
      Role,
      @EndUserText.label: 'Salary'
      Salary,
      @EndUserText.label: 'Active'
      Active,
      LastChangedAt,
      LocalLastChangedAt
}
```

- This view has labels, search which will be referred by fiori elements app
- Here is the place where we create associations
#### Other search documentation
- [Search.defaultSearchElement](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_1489485690-_ANNO.html)
- [Search.fuzzinessThreshold](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_294491798-_ANNO.html)
- [Search.mode](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_1895951254-_ANNO.html)
- [Search.ranking](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_1594409060-_ANNO.html)
- [Search.searchable](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_1567884046_ANNO.html)
- [Search.termMappingDictionary](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_568724386-_ANNO.html)
- [Search.termMappingListId](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_1460214714_ANNO.html)
- [Search.textIndex.required](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_284009624_ANNO.html)

#### Enduser text labels
- These will be list or table labels for fiori elements app
#### Endusertext documentation
- - [EndUserText.heading](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_92083118_ANNO.html)
- [EndUserText.label](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_924137870_ANNO.html)
- [EndUserText.quickInfo](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_26162021_ANNO.html)

## Step4 - Create Metadata extension

```
@Metadata.layer: #CORE
@UI: {
  headerInfo: { typeName: 'UX Team',
                typeNamePlural: 'UX Team',
                title: { type: #STANDARD, label: 'UXTeam', value: 'Id' }  },
                presentationVariant: [{ sortOrder: [{ by: 'Id', direction:  #ASC }] }] }

annotate view ZC_UXTEAM_5551 with
{

@UI.facet: [ { id:              'UXDemo',
                 purpose:         #STANDARD,
                 type:            #IDENTIFICATION_REFERENCE,
                 label:           'UXTeam',
                 position:        10 } ]

@UI:{ identification: [{ position: 1, label: 'Id' }] }
  Id;

  @UI: {  lineItem:       [ { position: 20 } ],
        identification: [ { position: 20 } ],
        selectionField: [ { position: 20 } ] }
  Firstname;

  @UI: {  lineItem:       [ { position: 30 } ],
        identification: [ { position: 30 } ],
        selectionField: [ { position: 30 } ] }
  Lastname;

  @UI: {  lineItem:       [ { position: 40 } ],
        identification: [ { position: 40 } ] }
  Age;
  
  @UI: {  lineItem:       [ { position: 50 } ],
        identification: [ { position: 50 } ] }
  Role;

   @UI: {  lineItem:       [ { position: 60 } ],
        identification: [ { position: 60 } ],
        selectionField: [ { position: 60 } ] }
  Salary;

  @UI: {  lineItem:       [ { position: 70 }, { type: #FOR_ACTION, dataAction: 'setActive', label: 'Set Active' } ],
        identification: [ { position: 70 }, { type: #FOR_ACTION, dataAction: 'setActive', label: 'Set Active' } ] }
  Active;
  
  @UI.hidden: true
  LastChangedAt;

  @UI.hidden: true
  LocalLastChangedAt;

}
```

- Here we update the UI annotations. This is similar to field catalog in alv

```link-bookmark
url:https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_UI_F.html
title:UI | ABAP Keyword Documentation
description:
coverImg:
logo:ABAPIcon.ico
```

## Step5 -  Create Behavior definition

![[Pasted image 20251112101107.png]]
- What can be done as behaviour
- use BDL - behavior definition language
- Documentation
```link-bookmark
url:https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENCDS_BDEF.html
title:RAP - Behavior Definitions | ABAP Keyword Documentation
description:
coverImg:
logo:ABAPIcon.ico
```

- [BDEF header](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENBDL_BDEF_HEADER.html)
- [entity behavior definition](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENBDL_DEFINE_BEH.html)
- [entity behavior characteristics](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENBDL_CHARACTER.html)
- [entity behavior body](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENBDL_BODY.html)
- [authorization context](https://help.sap.com/doc/abapdocu_cp_index_htm/CLOUD/en-US/ABENBDL_AUTHORIZATION_CONTEXT.html)

```
managed;
// with draft;

define behavior for ZI_UXTEAM_5551 alias UXTeam
implementation in class zbp_i_uxteam_5551 unique
persistent table zrap_uxteam_5551
// draft table zdr_uxteam_5551
lock master // total etag LastChangedAt
etag master LocalLastChangedAt
{
  create;
  update;
  delete;

  field ( numbering : managed, readonly ) Id;
  field ( readonly ) Active, Salary;
  field ( readonly ) LastChangedAt, LocalLastChangedAt;

  action ( features : instance ) setActive result [1] $self;
  determination changeSalary on save { field Role; }
  validation validateAge on save { field Age; create; }


  mapping for ZRAP_UXTEAM_5551
  {
    Id = id;
    FirstName = firstName;
    LastName = lastName;
    Age = age;
    Role = role;
    Salary = salary;
    Active = active;
    LastChangedAt = last_changed_at;
    LocalLastChangedAt = local_last_changed_at;
  }
}
```