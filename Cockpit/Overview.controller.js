sap.ui.define([
		"cockpitalerte/controllerAdds/BaseController",
		"sap/ui/model/json/JSONModel",
		"sap/ui/core/routing/History",
		"cockpitalerte/model/formatter",
		"sap/ui/model/Filter",
		"sap/ui/model/FilterOperator"
	], function (BaseController, JSONModel, History, formatter, Filter, FilterOperator) {
		"use strict";

		return BaseController.extend("cockpitalerte.controller.Overview", {

			formatter: formatter,

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

				// Make sure, busy indication is showing immediately so there is no
				// break after the busy indication for loading the view's meta data is
				// ended (see promise 'oWhenMetadataIsLoaded' in AppController)
				oTable.attachEventOnce("updateFinished", function(){
					// Restore original busy indicator delay for worklist's table
					oViewModel.setProperty("/tableBusyDelay", iOriginalBusyDelay);
				});
				
				this.InitModels();
				
				this.router = sap.ui.core.UIComponent.getRouterFor(this);
				this.router.attachRoutePatternMatched(this.handleRouting, this);
			},
			
			InitModels: function(){
				// Filter model
				this.getView().setModel( new sap.ui.model.json.JSONModel(), "QuickFilter" );
				
				this.getView().setModel( new sap.ui.model.json.JSONModel(), "History" );
				
				this.getView().setModel( new sap.ui.model.json.JSONModel(), "Main" );
				
				this.getView().setModel( new sap.ui.model.json.JSONModel(), "AlerteList" );
			},
			
			handleRouting: function(event) {
				var service	=	this.getView().getModel( "AlerteService" ),
					that	=	this;
				service.read("/HistorySet", {
					success: function(oData) {
						that.getView().getModel("History").setData(oData.results);
					},
					error: function(error) {
		
					}
				});
				
				service.read( "/MainSet", {
					urlParameters: 	"$expand=MN2AL",
					success: function ( oData ) {
						that.getView().getModel("Main").setData(oData);
						that.getView().getModel("AlerteList").setData(oData.results[0].MN2AL.results);
					},
					error: function(error) {
		
					}
				});
				
				
				// service.read("/AlerteSet", {
				// 	success: function(oData) {
				// 		that.getView().getModel("AlerteList").setData(oData.results);
				// 	},
				// 	error: function(error) {
		
				// 	}
				// });
			},
			
			/* =========================================================== */
			/* event handlers                                              */
			/* =========================================================== */

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
			 * Event handler for navigating back.
			 * It there is a history entry or an previous app-to-app navigation we go one step back in the browser history
			 * If not, it will navigate to the shell home
			 * @public
			 */
			onNavBack : function() {
				var sPreviousHash = History.getInstance().getPreviousHash(),
					oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation");

				if (sPreviousHash !== undefined || !oCrossAppNavigator.isInitialNavigation()) {
					history.go(-1);
				} else {
					oCrossAppNavigator.toExternal({
						target: {shellHash: "#Shell-home"}
					});
				}
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
						oTableSearchState = [new Filter("Matnr", FilterOperator.Contains, sQuery)];
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
				this.getRouter().navTo("object", {
					objectId: oItem.getBindingContext().getProperty("Matnr")
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
				
	selectAll: function( event ){
		var id			=	event.getSource().getId(),
			fieldName	=	"";
		if( id.includes( "App" ) ){
			fieldName	=	"AppList";
		}
		if( id.includes( "Change" ) ){
			fieldName	=	"ChangeList";
		}
		if( id.includes( "User" ) ){
			fieldName	=	"UserList";
		}
		var field		=	this.getView().byId( fieldName ),
			list		=	field.getItems(),
			items		=	[];
			
		jQuery.each( list , function( key, value ) {
			items.push( value.getKey() );
		});
		field.setSelectedKeys( items );
		this.handleSearch();
		this.checkAllSelected( event );
	},
	
	checkAllSelected: function( event ){
		var id			=	event.getSource().getId(),
			fieldName	=	"",
			iconId;
		if( id.includes( "App" ) ){
			fieldName	=	"AppList";
			iconId		=	"AppLi";
		}
		if( id.includes( "Change" ) ){
			fieldName	=	"ChangeList";
			iconId		=	"ChangeLi";
		}
		if( id.includes( "User" ) ){
			fieldName	=	"UserList";
			iconId		=	"UserLi";
		}
		var field		=	this.getView().byId( fieldName ),
			list		=	field.getItems();
		if( list.length === field.getSelectedKeys().length ){
			this.byId( iconId ).setVisible( false );
		}else{
			this.byId( iconId ).setVisible( true );
		}
	},
	removeFilter: function( event ){
		var id = event.getSource().getId().split("-");
		this.getView().getModel("QuickFilter").setProperty( "/" + id[ id.length - 1 ] , "" );
		this.checkAllSelected( event );
		// this.handleSearch();
	},
	gestionAlerte: function( event ){
			
		if( !this._newAlerte ){
			this._newAlerte = sap.ui.xmlfragment( "cockpitalerte.fragment.AlerteList", this);
			this.getView().addDependent(this._newAlerte);
		}
		
		this._newAlerte.open();
		this.handleAlerteSearch();
	},
	
	closeAlerte: function(){
		this._newAlerte.close();
	},
	
	handleAlerteSearch: function(){
		var segment		=	this._newAlerte.getAggregation("content")[0].getAggregation( "content" )[1].getSelectedKey(),
			table		=	this._newAlerte.getAggregation("content")[1].getBinding("items");
		
		switch (segment) {
			case "I":
				table.filter( new sap.ui.model.Filter("DESCR", sap.ui.model.FilterOperator.StartsWith, "MP" ) );       
				break;
			case "R":
				table.filter( new sap.ui.model.Filter("DESCR", sap.ui.model.FilterOperator.StartsWith, "RC" ) );       
				break;
			case "C":
				table.filter( new sap.ui.model.Filter("DESCR", sap.ui.model.FilterOperator.StartsWith, "CA" ) );       
				break;
		}
	},
	
	onSaveAlerte: function(){
		var currentView =	this.getView(),
			alrt		=	this.getView().getModel( "AlerteList" ).getData(),
			main		=	this.getView().getModel( "Main" ).getData(),
			service 	=	this.getView().getModel( "AlerteService" ),
			alrtToModif =	{},
			that		=	this,
			oMsgStrip	=	null,
			msgArea 	=	this.getView().byId( "msgArea" );
			msgArea.removeAllItems();
		
		
		
		//	Prepare object for server call
		alrtToModif			= main; 
		alrtToModif.MN2AL	= alrt;
	
		//	Set busy indicator
		currentView.setBusy( true );				

		//	Call server
		service.create( "/MainSet" , alrtToModif , {
			success: function( data, response ) {
				//	Disable busy indicator
				currentView.setBusy( false );				

				// if( response ){
				// 	//	Display message
				// 	var message 	=	JSON.parse(response.headers["sap-message"]);
				// 	sap.m.MessageToast.show( message.message , {duration: 3000});
				
				// }
			that.onEdit();
			
			},
			error: function( error ) {
				//	Disable busy indicator
					currentView.setBusy( false );
				
				oMsgStrip = new sap.m.MessageStrip({
										text: 				JSON.parse(error.responseText).error.message.value,
										showCloseButton: 	true,
										showIcon: 			true,
										type: 				"Error"
									});
				//	Add Message to VBox
				msgArea.addItem( oMsgStrip );
			} 
		});
	}
	
	// onSaveAlerte: function(){
	// 	var model	=	this.getView().getModel( "AlerteList" ),
	// 		service =	this.getView().getModel( "AlerteService" ),
	// 		that	=	this;
	// 	var param = {
	// 			method: "POST",
	// 			async:	false,
	// 			urlParameters: model.getData(),
	// 			success: function(data) {
	// 				model.setData( data );
	// 				that.getView().setBusy(false);
	// 				that._BusyDialog.close();
					
	// 			},
	// 			error: function(error) {
	// 				//	Disable busy indicator
	// 				that._BusyDialog.close();
					
	// 				//	Display message
	// 				sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
	// 			}
	// 		};
	
	// 		service.callFunction("/Save_alerte", param);
	// }


		});
	}
);