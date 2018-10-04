sap.ui.define([
		"iae/controllerAdds/BaseController",
		"sap/ui/model/json/JSONModel",
		"sap/ui/core/routing/History",
		"iae/model/Formatter",
		"sap/ui/model/Filter",
		"sap/ui/model/FilterOperator"
	], function (BaseController, JSONModel, History, formatter, Filter, FilterOperator) {
		"use strict";

		return BaseController.extend("iae.controller.Overview", {

			formatter: formatter,
			thisOverview: this,

			/* =========================================================== */
			/* lifecycle methods                                           */
			/* =========================================================== */

			/**
			 * Called when the worklist controller is instantiated.
			 * @public
			 */
			onInit : function () {
				var oViewModel,
					iOriginalBusyDelay,
					oTable = this.byId("table");
				
				// Put down worklist table's original value for busy indicator delay,
				// so it can be restored later on. Busy handling on the table is
				// taken care of by the table itself.
				iOriginalBusyDelay = oTable.getBusyIndicatorDelay();
				// keeps the search state
				this._oTableSearchState = [];

				// Model used to manipulate control states
				oViewModel = new JSONModel({
					worklistTableTitle : this.getResourceBundle().getText("worklistTableTitle"),
					saveAsTileTitle: this.getResourceBundle().getText("worklistViewTitle"),
					shareOnJamTitle: this.getResourceBundle().getText("worklistViewTitle"),
					shareSendEmailSubject: this.getResourceBundle().getText("shareSendEmailWorklistSubject"),
					shareSendEmailMessage: this.getResourceBundle().getText("shareSendEmailWorklistMessage", [location.href]),
					tableNoDataText : this.getResourceBundle().getText("tableNoDataText"),
					tableBusyDelay : 0
				});
				this.setModel(oViewModel, "worklistView");
				
				this.router 	= sap.ui.core.UIComponent.getRouterFor(this);
				this.router.attachRoutePatternMatched( this.handleRouting , this);
					
				// Make sure, busy indication is showing immediately so there is no
				// break after the busy indication for loading the view's meta data is
				// ended (see promise 'oWhenMetadataIsLoaded' in AppController)
				oTable.attachEventOnce("updateFinished", function(){
					// Restore original busy indicator delay for worklist's table
					oViewModel.setProperty("/tableBusyDelay", iOriginalBusyDelay);
				});
				
				// Filter model
				this.getView().setModel( new sap.ui.model.json.JSONModel(), "QuickFilter" );
				
				// Set search on filter site on contain
				this.byId("searchSite").setFilterFunction(function(sTerm, oItem) {
					// A case-insensitive 'string contains' style filter
					return oItem.getText().match(new RegExp(sTerm, "i"));
				});
				
				// Set search on filter "Fournisseur" on contain
				this.byId("searchFournisseur").setFilterFunction(function(sTerm, oItem) {
					// A case-insensitive 'string contains' style filter
					return oItem.getText().match(new RegExp(sTerm, "i"));
				});
				// Model du nombre de ligne de la table principal en fonction de la taille de l'ecran
				this.getView().setModel( new sap.ui.model.json.JSONModel({
																			Screen		:	17
																			}), "OverviewScreenModel" );
				// Defini le nombre de ligne dans la principal
				this._screenSize();
			},
			
			/**
			 *	Fonction qui defini le nombre de ligne en fonction de la taille de l'ecran
			 */
			_screenSize:function(){
				// récupere la taille de l'ecran
				var screenR		=	window.innerHeight,
					edit		=	this.getView().getModel( "OverviewScreenModel" );
				
				if( screenR <= 600 ){
					edit.setProperty( "/Screen" , 9 );
				}else if( screenR <= 650 ){
					edit.setProperty( "/Screen" , 10 );
				}else if( screenR <= 700 ){
					edit.setProperty( "/Screen" , 11 );
				}else if( screenR <= 750 ){
					edit.setProperty( "/Screen" , 12 );
				}else if( screenR <= 800 ){
					edit.setProperty( "/Screen" , 13 );
				}else if( screenR	<=	850 ){
					edit.setProperty( "/Screen" , 14 );
				}else if( screenR	<=	900 ){
					edit.setProperty( "/Screen" , 15 );
				}else{
					edit.setProperty( "/Screen" , 16 );
				}	
			},

			/* =========================================================== */
			/* event handlers                                              */
			/* =========================================================== */
			
			handleRouting: function( oEvent ){
				// Set the pre-selected status on filter status
				this.byId("multiComboBox").setSelectedKeys( [ "01" , "02" , "03" , "06"] );
				this.handleSearch();
			},
			
			
			/**
			 * Triggered by the table's 'updateFinished' event: after new table
			 * data is available, this handler method updates the table counter.
			 * This should only happen if the update was successful, which is
			 * why this handler is attached to 'updateFinished' and not to the
			 * table's list binding's 'dataReceived' method.
			 * @param {sap.ui.base.Event} oEvent the update finished event
			 * @public
			 */
			onUpdateFinished : function (oEvent) {
				// update the worklist's object counter after the table update
				var sTitle,
					oTable = oEvent.getSource(),
					iTotalItems = oEvent.getParameter("total");
				// only update the counter if the length is final and
				// the table is not empty
				if (iTotalItems && oTable.getBinding("items").isLengthFinal()) {
					sTitle = this.getResourceBundle().getText("worklistTableTitleCount", [iTotalItems]);
				} else {
					sTitle = this.getResourceBundle().getText("worklistTableTitle");
				}
				this.getModel("worklistView").setProperty("/worklistTableTitle", sTitle);
				
				
			},

			/**
			 * Event handler when a table item gets pressed
			 * @param {sap.ui.base.Event} oEvent the table selectionChange event
			 * @public
			 */
			onPress : function (oEvent) {
				// The source is the list item that got pressed
				this._showObject(oEvent.getSource());
			},
			
			/**
			 * New devis function
			 * Navigation to creation view 
			 */
			NewDevis:	function(){
				this.getRouter().navTo("NouveauDevis",{ objectId: "N" });	
				// sap.m.MessageToast.show( "A venir" );
			},

			/**
			 * Event handler when the share in JAM button has been clicked
			 * @public
			 */
			onShareInJamPress : function () {
				var oViewModel = this.getModel("worklistView"),
					oShareDialog = sap.ui.getCore().createComponent({
						name: "sap.collaboration.components.fiori.sharing.dialog",
						settings: {
							object:{
								id: location.href,
								share: oViewModel.getProperty("/shareOnJamTitle")
							}
						}
					});
				oShareDialog.open();
			},

			onSearch : function (oEvent) {
				if (oEvent.getParameters().refreshButtonPressed) {
					// Search field's 'refresh' button has been pressed.
					// This is visible if you select any master list item.
					// In this case no new search is triggered, we only
					// refresh the list binding.
					this.onRefresh();
				} else {
					var oTableSearchState = [];
					var sQuery = oEvent.getParameter("query");

					if (sQuery && sQuery.length > 0) {
						oTableSearchState = [new Filter("DESCR", FilterOperator.Contains, sQuery)];
					}
					this._applySearch(oTableSearchState);
				}

			},

			/**
			 * Event handler for refresh event. Keeps filter, sort
			 * and group settings and refreshes the list binding.
			 * @public
			 */
			onRefresh : function () {
				var oTable = this.byId("table");
				oTable.getBinding("items").refresh();
			},

			/* =========================================================== */
			/* internal methods                                            */
			/* =========================================================== */

			/**
			 * Shows the selected item on the object page
			 * On phones a additional history entry is created
			 * @param {sap.m.ObjectListItem} oItem selected Item
			 * @private
			 */
			_showObject : function (oItem) {
				var path	=	oItem.getBindingInfo( "text" ).binding.getContext().getPath(),
					key 	=	this.getModel().getProperty( path + "/DAMNB" );
				this.getRouter().navTo("Detail", {
					objectId: key
				});
			},

			/**
			 * Internal helper method to apply both filter and search state together on the list binding
			 * @param {object} oTableSearchState an array of filters for the search
			 * @private
			 */
			_applySearch: function(oTableSearchState) {
				var oTable = this.byId("table"),
					oViewModel = this.getModel("worklistView");
				oTable.getBinding("items").filter(oTableSearchState, "Application");
				// changes the noDataText of the list in case there are no filter results
				if (oTableSearchState.length !== 0) {
					oViewModel.setProperty("/tableNoDataText", this.getResourceBundle().getText("worklistNoDataWithSearchText"));
				}
			},
			
			/**
			 * Clear filter function
			 */
			onClearFilter: function(){
				
				this.byId( "multiIntervenant" ).removeAllTokens();
				this.getView().getModel( "QuickFilter" ).setData({});
				this.handleSearch();
			},
			/**
			 * Builder of the filters of the table
			 */
			_buildFilters: function () {
				var filterData 	=	this.getView().getModel( "QuickFilter" ).getData(),
					multi		=	this.byId( "multiComboBox" ).getSelectedKeys(),
					customFilter=	null,
					filters 	=	[];
		
				if( filterData.DateFrom ) {
					//	Filter on begin date
					filters.push(	new sap.ui.model.Filter( "ERDAT" , sap.ui.model.FilterOperator.GE , filterData.DateFrom ) );
				}
		
				if( filterData.DateTo ) {
					//	Filter on end date
					filters.push(	new sap.ui.model.Filter( "ERDAT" , sap.ui.model.FilterOperator.LE , filterData.DateTo ) );	
				}
				
				if( filterData.Fournisseur ) {
					//	Filter on fournisseur
					filters.push(	new sap.ui.model.Filter( "LIFNR" , sap.ui.model.FilterOperator.EQ , filterData.Fournisseur.split("-")[0] ) );	
				}
				if( filterData.Montant ) {
					//	Filter on montant
					filters.push(	new sap.ui.model.Filter( "NETPR" , sap.ui.model.FilterOperator.EQ , filterData.Montant ) );	
				}
				
				if( filterData.Site ) {
					//	Filter on site
					filters.push(	new sap.ui.model.Filter( "WERKS" , sap.ui.model.FilterOperator.EQ , filterData.Site.split("-")[0] ) );	
				}
		
				if( multi.length > 0 ) {
					customFilter	=	[];
					//	Filter on multi status
					for (var i=0; i<multi.length; i++) {
						customFilter.push( new sap.ui.model.Filter( "STATS" , sap.ui.model.FilterOperator.EQ , multi[i] ) );
					}
					filters.push( new sap.ui.model.Filter( customFilter, false ) );
				}
				
				return filters;
			},
			
			/**
			 *	Filter liveChange of all filters of the table
			 */
			handleSearch: function( event ){
				var binding 	=	this.byId( "table" ).getBinding("rows"),
					filters 	=	this._buildFilters();
					
					if( filters.length > 0 ){
						binding.filter( new sap.ui.model.Filter({
							filters:	filters,
		    				and:		true
		    			}));
					}else{
						binding.filter( null );
					}
			}

		});
	}
);