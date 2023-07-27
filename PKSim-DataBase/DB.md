# General remarks

Some of the common properties used in many tables:

* **display_name** The name of the entity to be used in the UI in PK-Sim.

  NOTE: MoBi does not support the "display name" concept, so all entities are displayed with their internal name. Also within a model all objects are stored with their internal name. It is therefore advisable to keep the display name the same as the internal name. Exceptions are e.g. special characters like "*", "|" etc. which cannot be used in internal names. 

* **description** Longer description of the entity, which is displayed as a tooltip in PK-Sim and can be edited in MoBi.

* **sequence** Used to sort objects in the UI (unless another sorting algorithm applies, e.g. alphabetical).

* **icon_name** Defines which icon is used for the entity. 

  If not empty: the icon with the given name must be present in the `OSPSuite.Assets.Images`

Boolean values are always represented as **integers restricted to {0, 1}**.

# Overview diagrams

Each of the following subsections focuses on one aspect and shows only a **subset** of the database tables relevant to that topic. The last subsection shows the complete schema with all tables.

## Containers

A **container** is a model entity that can have children. In the context of PK-Sim, everything except parameters and observers is a container.

![](images/overview_containers.png)

**tab_container_names** describes an abstract container (e.g. "Plasma"), which can be inserted at various places in the container structure defined in **tab_containers**.

* **container_type** is used, for example, to map a container to the correct container class in PK-Sim.
* **extension** is not used by PK-Sim and is only useful for some database update scripts.
* **icon_name** defines which icon is used for a container. 

**tab_containers** defines the container hierarchy and includes **all possible containers** which can appear in a model. When a model is created, some containers are filtered out based on the information in **tab_model_containers** and **tab_population_containers** (s. below)

* Each container within a hierarchy is identified by the combination 
  `{container_id, container_type, container_name}`. 

  * `container_id` is unique across all containers. In principle, it would be sufficient to use only the *container id* as the primary key. Container type and container name have been included in the primary key for convenience (e.g. when querying data from other tables, it is not always necessary to include *tab_containers* and *tab_container_names* etc.). 

* Each container can have a parent container defined by the combination
  `{parent_container_id, parent_container_type, parent_container_name}`. 

  * Containers that appear at the top level of the *Spatial Structure* are defined as children of the special `ROOT` container. The `ROOT` container itself has no parent.

    | container_id | container_type | container_name     | parent_container_id | parent_container_type | parent_container_name |
    | ------------ | -------------- | ------------------ | ------------------- | --------------------- | --------------------- |
    | 146          | ORGANISM       | Organism           | 145                 | SIMULATION            | ROOT                  |
    | 777          | GENERAL        | Neighborhoods      | 145                 | SIMULATION            | ROOT                  |
    | 1026         | GENERAL        | MoleculeProperties | 145                 | SIMULATION            | ROOT                  |
    | 4205         | GENERAL        | Events             | 145                 | SIMULATION            | ROOT                  |

  * Top containers of other building blocks (Passive Transports, Reactions, Events, Formulations, ...) are all defined as containers without a parent. 

* **tab_containers.visible** defines if a container is shown in PK-Sim in hierarchy view (TODO rename column to **is_visible**).

* **tab_containers.is_logical** defines if a container is *physical* or *logical* (s. the [OSP documentation](https://docs.open-systems-pharmacology.org/working-with-mobi/mobi-documentation/model-building-components#spatial-structures) for details).

**tab_container_tags** describes which additional tags are added to a container.

* the **name** of a container is always added as a tag programmatically and does not need to be added here.

**tab_neighborhoods** defines 2 neighbor containers for each neighborhood of a spatial structure

* There are no rules or restrictions as to which of 2 adjacent containers must be defined as the first and which as the second container. For example, passive transports are defined by the container criteria of their source and target containers, and changing the first and second neighbour containers does not affect the later creation of the transport. Care should only be taken when using the keywords FIRST_NEIGHBOR and SECOND_NEIGHBOR in the formulas. 
  * Even in the latter case, swapping neighbors may not be critical. E.g. if both neighbor containers have **the same parent container** and the formula uses the path `FIRST_NEIGHBOR|..|Parameter1`, then swapping the formula path with `SECOND_NEIGHBOR|..|Parameter1`would result in the same formula, because F`IRST_NEIGHBOR|..` and `SECOND_NEIGHBOR|..` both point to the same container, making the formula invariant with respect to neighbor switching. 
  * But if the formula refers e.g. to `FIRST_NEIGHBOR|Parameter1` - then the neighbor order is relevant.

**tab_population_containers** defines which containers are created in individual/population building blocks in PK-Sim. For each population, this is a subset of the containers defined in *tab_containers*. 

**tab_model_containers** defines which containers **can** be included into the final model. Whether a container is included into the model is estimated based on the value of the column **usage_in_individual** as following:

* if `usage_in_individual = REQUIRED`
  * if the container is available in the individual/population building block used for the model creation: container is added to the model
  * otherwise: error, model cannot be created
* if `usage_in_individual = OPTIONAL`
  * if the container is available in the individual/population building block used for the model creation: container is added to the model
  * otherwise: container is NOT added to the model
* if `usage_in_individual = EXTENDED`
  * container is added to the model in any case
  * containers of this type usually should not be defined in *tab_population_containers* (TODO https://github.com/Yuri05/DB_Questions/discussions/1)

## Processes

Processes are defined as containers with `container_type="PROCESS"` and must be inserted into **tab_container_names** first; once done they can be inserted into **tab_processes** and further process-specific tables.

![](images/overview_processes.png)



**tab_processes.template** defines whether a process is always added to the selected model or only on demand.

* For example, all passive transports or FcRn binding reactions in a protein model have `template = 0`

* For example, active transports or metabolization reactions which are added only if the corresponding process was configured in a simulation in PK-Sim have `template = 1`

**tab_processes.group** is used to identify where the processes are used in PK-Sim.

| GROUP_NAME                    | PARENT_GROUP       |
| ----------------------------- | ------------------ |
| ACTIVE_TRANSPORT              | COMPOUND_PROCESSES |
| ACTIVE_TRANSPORT_INTRINSIC    | COMPOUND_PROCESSES |
| APPLICATION                   |                    |
| ENZYMATIC_STABILITY           | COMPOUND_PROCESSES |
| ENZYMATIC_STABILITY_INTRINSIC | COMPOUND_PROCESSES |
| INDIVIDUAL_ACTIVE_PROCESS     |                    |
| INDUCTION_PROCESSES           | COMPOUND_PROCESSES |
| INHIBITION_PROCESSES          | COMPOUND_PROCESSES |
| PROTEIN                       |                    |
| SIMULATION_ACTIVE_PROCESS     |                    |
| SPECIFIC_BINDING              | COMPOUND_PROCESSES |
| SYSTEMIC_PROCESSES            | COMPOUND_PROCESSES |
| UNDEFINED                     |                    |

* Processes with the **parent** group *COMPOUND_PROCESSES* are templates for active processes (active transport, specific binding, elimination, metabolization, inhibition, induction, ...) used in the compound building block of PK-Sim.
* Processes with the group *APPLICATION* are application transports.
* Processes with the group *INDIVIDUAL_ACTIVE_PROCESS* are templates for *active transports*, used in an *Expression Profile* building block. These templates have no parameters and are further specified in **tab_transports** (s. below).
* Processes with the group *PROTEIN* describe *production* and *degradation* of proteins (enzymes, transporters, binding partners).
* Processes with the group *SIMULATION_ACTIVE_PROCESS* describe the processes which are created in a simulation from both compound process template and individual (expression profile) process template.
* Processes with the group *UNDEFINED* are processes where the group is not relevant (typically all *passive* processes).

**tab_processes.kinetic_type** is used for the mapping                                                                                            `{Compound process template, Individual process template} ==> Simulation process`

Example: active transports

* for the active transports there are currently 2 compound templates:

| process                      | group_name       | kinetic_type |
| ---------------------------- | ---------------- | ------------ |
| ActiveTransportSpecific_Hill | ACTIVE_TRANSPORT | Hill         |
| ActiveTransportSpecific_MM   | ACTIVE_TRANSPORT | MM           |

* there are different individual active transport templates - specified by their source and target (Interstitial<=>Intracellular, Interstitial<=>Plasma, Blood Cells <=> Plasma etc.)

(kinetic type is not specified on the individual building block level and thus is set to "*Undefined*")

| process                                         | group_name                | kinetic_type |
| - | ------------------------- | ------------ |
| ActiveEffluxSpecificIntracellularToInterstitial | INDIVIDUAL_ACTIVE_PROCESS | Undefined    |
| ActiveInfluxSpecificInterstitialToIntracellular | INDIVIDUAL_ACTIVE_PROCESS | Undefined    |
| ActiveEffluxSpecificInterstitialToPlasma        | INDIVIDUAL_ACTIVE_PROCESS | Undefined    |
| ActiveInfluxSpecificPlasmaToInterstitial        | INDIVIDUAL_ACTIVE_PROCESS | Undefined    |
|  ...       | ...                       | ...          |

* In the simulation

`ActiveTransportSpecific_MM (Compound) + ActiveEffluxSpecificIntracellularToInterstitial (Individual) ▶️ ActiveEffluxSpecificIntracellularToInterstitial_MM (Simulation)`

`ActiveTransportSpecific_Hill (Compound) + ActiveEffluxSpecificIntracellularToInterstitial (Individual) ▶️ ActiveEffluxSpecificIntracellularToInterstitial_Hill (Simulation)`

| process                                              | group_name                | kinetic_type |
| :--------------------------------------------------- | ------------------------- | ------------ |
| ActiveEffluxSpecificIntracellularToInterstitial_Hill | SIMULATION_ACTIVE_PROCESS | Hill         |
| ActiveEffluxSpecificIntracellularToInterstitial_MM   | SIMULATION_ACTIVE_PROCESS | MM           |
| ActiveInfluxSpecificInterstitialToIntracellular_Hill | SIMULATION_ACTIVE_PROCESS | Hill         |
| ActiveInfluxSpecificInterstitialToIntracellular_MM   | SIMULATION_ACTIVE_PROCESS | MM           |
| ActiveEffluxSpecificInterstitialToPlasma_Hill        | SIMULATION_ACTIVE_PROCESS | Hill         |
| ActiveEffluxSpecificInterstitialToPlasma_MM          | SIMULATION_ACTIVE_PROCESS | MM           |
| ActiveInfluxSpecificPlasmaToInterstitial_Hill        | SIMULATION_ACTIVE_PROCESS | Hill         |
| ActiveInfluxSpecificPlasmaToInterstitial_MM          | SIMULATION_ACTIVE_PROCESS | MM           |
| ...                                                  | ...                       | ...          |

**tab_processes.process_type** is used for more detailed process specification within a group. (TODO better description)

| group_name                    | process_type             |
| ----------------------------- | ------------------------ |
| ACTIVE_TRANSPORT              | ActiveTransport          |
| ACTIVE_TRANSPORT_INTRINSIC    | ActiveTransport          |
| APPLICATION                   | Application              |
| ENZYMATIC_STABILITY           | Metabolization           |
| ENZYMATIC_STABILITY_INTRINSIC | Metabolization           |
| INDIVIDUAL_ACTIVE_PROCESS     | BiDirectional            |
| INDIVIDUAL_ACTIVE_PROCESS     | Efflux                   |
| INDIVIDUAL_ACTIVE_PROCESS     | Influx                   |
| INDIVIDUAL_ACTIVE_PROCESS     | PgpLike                  |
| INDUCTION_PROCESSES           | Induction                |
| INHIBITION_PROCESSES          | CompetitiveInhibition    |
| INHIBITION_PROCESSES          | IrreversibleInhibition   |
| INHIBITION_PROCESSES          | MixedInhibition          |
| INHIBITION_PROCESSES          | NoncompetitiveInhibition |
| INHIBITION_PROCESSES          | UncompetitiveInhibition  |
| PROTEIN                       | Creation                 |
| SIMULATION_ACTIVE_PROCESS     | BiDirectional            |
| SIMULATION_ACTIVE_PROCESS     | Efflux                   |
| SIMULATION_ACTIVE_PROCESS     | Induction                |
| SIMULATION_ACTIVE_PROCESS     | Influx                   |
| SIMULATION_ACTIVE_PROCESS     | IrreversibleInhibition   |
| SIMULATION_ACTIVE_PROCESS     | PgpLike                  |
| SPECIFIC_BINDING              | SpecificBinding          |
| SYSTEMIC_PROCESSES            | Elimination              |
| SYSTEMIC_PROCESSES            | EliminationGFR           |
| SYSTEMIC_PROCESSES            | Metabolization           |
| SYSTEMIC_PROCESSES            | Secretion                |
| UNDEFINED                     | Passive                  |

**tab_processes.action_type** is one of {`APPLICATION`, `INTERACTION`, `REACTION`, `TRANSPORT`} (TODO better description)

**tab_processes.create_process_rate_parameter** defines if the `Process Rate` parameter for should be created for transport or reaction (s. [OSP Suite documentation](https://docs.open-systems-pharmacology.org/working-with-mobi/mobi-documentation/model-building-components#reactions-and-molecules) for details.)

**tab_process_descriptor_conditions** describes source and target container criteria for transports and (source) container criteria for reactions

**tab_process_molecules** describes some reactions which are **always** part of a model (like FcRn binding)

* **tab_process_molecules.direction** can be of `IN` (educt), `OUT` (product) or `MODIFIER`

**tab_process_rates** describes the rate (kinetic) of a process

* Template processes with the **parent** group **COMPOUND_PROCESSES** and processes with the group **INDIVIDUAL_ACTIVE_PROCESS** always have `Zero_Rate` formula, because they are used in the corresponding building blocks where the process rate does not matter. The real rate is then set for the corresponding **simulation** process, e.g. 

  | process                                            | calculation_method | formula_rate                                   |
  | -------------------------------------------------- | ------------------ | ---------------------------------------------- |
  | ActiveTransportSpecific_MM                         | LinksCommon        | Zero_Rate                                      |
  | ActiveEffluxSpecificIntracellularToInterstitial    | LinksCommon        | Zero_Rate                                      |
  | ActiveEffluxSpecificIntracellularToInterstitial_MM | LinksCommon        | ActiveEffluxSpecificWithTransporterInTarget_MM |

**tab_model_transport_molecule_names** restricts which molecules are transported by a (passive) transport for particular model. As per default, a transport will transfer all floating molecules from its source container to the target container. In this table, some molecules can be excluded (`should_transport=0`) or transport can be restricted only to the specific molecules (`should_transport=1`). S. the [Passive Transports documentation](https://docs.open-systems-pharmacology.org/working-with-mobi/mobi-documentation/model-building-components#passive-transports)

**tab_transports** defines which (active) transports can be created in the model. (TODO better description, s. also the issue https://github.com/Open-Systems-Pharmacology/PK-Sim/issues/2309)

**tab_transport_directions** (TODO s. the issue https://github.com/Open-Systems-Pharmacology/PK-Sim/issues/2310)

**tab_active_transports** (TODO https://github.com/Yuri05/DB_Questions/discussions/5)

## Species and populations

**Species** defines the type of an individual (Human, Dog, Rat, Mouse, ...)

**Population** defines a subtype of a species. For each species, 1 or more populations can be defined.

![](images/overview_species_and_populations.png)

**tab_species.user_defined** (TODO https://github.com/Yuri05/DB_Questions/discussions/6)

**tab_species.is_human** (TODO https://github.com/Yuri05/DB_Questions/discussions/7)

**tab_species_calculation_methods** If a parameter is defined by **formula** - this formula must be described by a *calculation method* (s. the [Calculation methods and parameter value versions](#calculation-methods-and-parameter-value-versions) section for details). In such a case, this calculation method must be assigned to the species, which happens in **tab_species_calculation_methods**. 

* E.g. the calculation method `Lumen_Geometry` describes the calculation of some GI-related parameters based on the age and body height, which is currently applicable only to the species `Human`. Thus this calculation method is defined only for `Human` in the table

**tab_species_parameter_value_versions** is the counterpart of *tab_species_calculation_methods* for parameters defined by a **constant value**. All constant values must be described by a *parameter value version* (s. the [Calculation methods and parameter value versions](#calculation-methods-and-parameter-value-versions) section for details).

One of the reasons for introducing calculation methods and parameter value versions is that sometimes we have more than one possible alternative for defining a set of parameters.

* E.g. we have several alternatives for the calculation of body surface area in humans. The corresponding entries in the table **tab_species_calculation_methods** are shown below. 

  | species | calculation_method            |
  | ------- | ----------------------------- |
  | Human   | Body surface area - Du Bois   |
  | Human   | Body surface area - Mosteller |

  The fact that the above calculation methods are **alternatives** is defined by the fact that both have the same **category** defined in **tab_calculation_methods** (see section [Calculation Methods and Parameter Value Versions](#calculation-methods-and-parameter-value-versions) for details). In PK-Sim, the user then has to select exactly one of these calculation methods (in the above example - during the individual creation, because the described parameters belong to the individual building block).
  
  ![](images/Screen01_SelectCalculationMethod.png)

## Container parameters

![](images/overview_container_parameters.png)



## Calculation method parameters

![](images/overview_calculation_method_parameters.png)



## Formulas (Calculation method - rates)

![](images/overview_calculation_method_rates.png)



## Calculation methods and parameter value versions

![](images/overview_CM_and_PVV.png)



## Applications and formulations

![](images/overview_applications_formulations.png)



## Categories

![](images/overview_categories.png)



## Entities defined by formulas

![](images/overview_formula_objects.png)



## Events

![](images/overview_events.png)



## Observers

![](images/overview_observers.png)

## Proteins

![](images/overview_proteins.png)

## Models

![](images/overview_models.png)



## Tags

![](images/overview_tags.png)



## Value origins

![](images/overview_value_origins.png)

## Representation Info

![](images/overview_representation_info.png)

## Enumerations

![](images/overview_enums_1.png)

![](images/overview_enums_2.png)

![](images/overview_enums_3.png)

![](images/overview_enums_4.png)

![](images/overview_enums_5.png)

![](images/overview_enums_6.png)

# Full schema

![](images/full_db_tables.png)