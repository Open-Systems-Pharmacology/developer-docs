rem @echo off

rem -----------------------------------------------------------------------------------
rem adjust paths before execution
set pathToSchemaCrawler=C:\Dev\Install2Move\DBDocu\schemacrawler-16.20.3-bin\bin
set pathToPKSimDB=C:\SW-Dev\PK-Sim\branches\11.0\src\Db\PKSimDB.sqlite
rem -----------------------------------------------------------------------------------

set path=%pathToSchemaCrawler%;%path%
set scOptions=--server=sqlite --info-level=standard --command=schema --portable-names --no-info=true --database="%pathToPKSimDB%"

call schemacrawler.bat %scOptions% --tables="tab_containers|tab_container_names|tab_container_tags|tab_container_types|tab_organ_types|tab_model_containers|tab_population_containers|tab_neighborhoods" --output-file=overview_containers.png
call schemacrawler.bat %scOptions% --tables="tab_active_transport_types|tab_known_transporters|tab_known_transporters_containers|tab_container_names|tab_groups|tab_kinetic_types|tab_model_transport_molecule_names|tab_processes|tab_process_descriptor_conditions|tab_process_molecules|tab_process_rates|tab_process_types|tab_transports|tab_transport_directions" --output-file=overview_processes.png
call schemacrawler.bat %scOptions% --tables="tab_containers|tab_container_names|tab_disease_states|tab_genders|tab_model_species|tab_ontogenies|tab_populations|tab_population_age|tab_population_containers|tab_population_disease_states|tab_population_genders|tab_species|tab_species_calculation_methods|tab_species_parameter_value_versions" --output-file=overview_species_and_populations.png
call schemacrawler.bat %scOptions% --tables="tab_groups|tab_calculation_method_rates|tab_compound_process_parameter_mapping|tab_containers|tab_container_parameters|tab_container_parameter_curves|tab_distribution_types|tab_container_parameter_rates|tab_container_parameter_rhs|tab_container_parameter_values|tab_molecule_parameters|tab_parameters|tab_container_parameter_descriptor_conditions|tab_dimensions|tab_criteria_conditions" --output-file=overview_container_parameters.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_method_rates|tab_container_parameters|tab_container_parameter_fcurves|tab_distribution_types" --output-file=overview_container_parameters_fcurves.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_method_parameter_descr_conditions|tab_calculation_method_parameter_rates|tab_calculation_method_rates|tab_groups|tab_parameters|tab_tags" --output-file=overview_calculation_method_parameters.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_methods|tab_calculation_method_rates|tab_calculation_method_rate_descriptor_conditions|tab_categories|tab_object_paths|tab_rates|tab_rate_container_molecules|tab_rate_container_parameters|tab_rate_generic_molecules|tab_rate_generic_parameters|tab_tags|tab_dimensions|tab_container_names|tab_criteria_conditions" --output-file=overview_calculation_method_rates.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_methods|tab_categories|tab_models|tab_model_calculation_methods|tab_parameter_value_versions|tab_species|tab_species_calculation_methods|tab_species_parameter_value_versions" --output-file=overview_CM_and_PVV.png
call schemacrawler.bat %scOptions% --tables="tab_applications|tab_application_types|tab_container_names|tab_formulation_routes|tab_containers" --output-file=overview_applications_formulations.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_method_parameter_rates|tab_calculation_method_rate_descriptor_conditions|tab_calculation_method_rates|tab_container_molecule_start_formulas|tab_container_parameter_rates|tab_container_parameter_rhs|tab_container_rates|tab_event_changed_container_molecules|tab_event_changed_container_parameters|tab_event_changed_generic_molecules|tab_event_changed_generic_parameters|tab_event_conditions|tab_observer_rates|tab_process_rates" --output-file=overview_formula_objects.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_method_rates|tab_containers|tab_event_changed_container_molecules|tab_event_changed_container_parameters|tab_event_changed_generic_molecules|tab_event_changed_generic_parameters|tab_event_conditions|tab_object_paths|tab_parameters" --output-file=overview_events.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_method_rates|tab_dimensions|tab_observers|tab_observer_descriptor_conditions|tab_observer_rates|tab_tags" --output-file=overview_observers.png
call schemacrawler.bat %scOptions% --tables="tab_calculation_methods|tab_containers|tab_models|tab_model_calculation_methods|tab_model_containers|tab_container_molecules|tab_model_container_molecules|tab_model_observers|tab_model_species|tab_model_transport_molecule_names|tab_molecules|tab_observers|tab_processes|tab_species|tab_container_molecule_start_formulas" --output-file=overview_models.png
call schemacrawler.bat %scOptions% --tables="tab_tags|tab_container_tags|tab_calculation_method_parameter_descr_conditions|tab_calculation_method_rate_descriptor_conditions|tab_container_parameter_descriptor_conditions|tab_criteria_conditions|tab_observer_descriptor_conditions|tab_process_descriptor_conditions" --output-file=overview_tags.png
call schemacrawler.bat %scOptions% --tables="tab_container_molecule_start_formulas|tab_container_parameter_curves|tab_container_parameter_rates|tab_container_parameter_values|tab_references|tab_value_origins" --output-file=overview_value_origins.png
call schemacrawler.bat %scOptions% --tables="tab_molecule_parameters|tab_protein_names|tab_protein_synonyms|tab_ontogenies" --output-file=overview_proteins.png
call schemacrawler.bat %scOptions% --tables="tab_representation_info" --output-file=overview_representation_info.png

rem call schemacrawler.bat %scOptions% --tables="tab_application_types|tab_applications" --output-file=overview_enums_1.png
rem call schemacrawler.bat %scOptions% --tables="tab_container_types|tab_container_names" --output-file=overview_enums_2.png
rem call schemacrawler.bat %scOptions% --tables="tab_distribution_types|tab_container_parameter_curves|tab_molecule_parameters" --output-file=overview_enums_3.png
rem call schemacrawler.bat %scOptions% --tables="tab_kinetic_types|tab_processes" --output-file=overview_enums_4.png
rem call schemacrawler.bat %scOptions% --tables="tab_organ_types" --output-file=overview_enums_5.png
rem call schemacrawler.bat %scOptions% --tables="tab_active_transport_types|tab_known_transporters|tab_process_types|tab_processes" --output-file=overview_enums_6.png

call schemacrawler.bat %scOptions% --tables="tab_.*" --output-file=full_db_tables.png

pause
