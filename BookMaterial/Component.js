sap.ui.define([
		"sap/ui/core/UIComponent",
		"sap/ui/Device",
		"iae/model/models",
		"iae/controllerAdds/ErrorHandler"
	], function (UIComponent, Device, models, ErrorHandler) {
		"use strict";

		return UIComponent.extend("iae.Component", {

			metadata : {
				manifest: "json"
			},
			
			batchGroup: "xcChgGrp",

			/**
			 * The component is initialized by UI5 automatically during the startup of the app and calls the init method once.
			 * In this function, the FLP and device models are set and the router is initialized.
			 * @public
			 * @override
			 */
			init : function () {
				// call the base component's init function
				UIComponent.prototype.init.apply(this, arguments);

				// initialize the error handler with the component
				this._oErrorHandler = new ErrorHandler(this);

				// set the device model
				this.setModel(models.createDeviceModel(), "device");
				
				// set the FLP model
				this.setModel(models.createFLPModel(), "FLP");

				// create the views based on the url/hash
				this.getRouter().initialize();
				
				// Configure Batch Groups
				this._configureBatchGroups();
				
				
				//	Set Service Size limit
				this.getModel().setSizeLimit( 100000 );
				//	Set Service Size limit
				this.getModel( "VHModel" ).setSizeLimit( 100000 );
				
				var that = this;
				this.getModel().read( "/VH_SITESSet" , {
					success: function( oData ) {
                    	that.setModel( new sap.ui.model.json.JSONModel({ WERKS	:	oData.results[0].WERKS }), "Site" );
                    },
                	error: function( error ) {
                     
                    }
                });
			},

			/**
			 * The component is destroyed by UI5 automatically.
			 * In this method, the ErrorHandler is destroyed.
			 * @public
			 * @override
			 */
			destroy : function () {
				this._oErrorHandler.destroy();
				// call the base component's destroy function
				UIComponent.prototype.destroy.apply(this, arguments);
			},

			/**
			 * This method can be called to determine whether the sapUiSizeCompact or sapUiSizeCozy
			 * design mode class should be set, which influences the size appearance of some controls.
			 * @public
			 * @return {string} css class, either 'sapUiSizeCompact' or 'sapUiSizeCozy' - or an empty string if no css class should be set
			 */
			getContentDensityClass : function() {
				if (this._sContentDensityClass === undefined) {
					// check whether FLP has already set the content density class; do nothing in this case
					if (jQuery(document.body).hasClass("sapUiSizeCozy") || jQuery(document.body).hasClass("sapUiSizeCompact")) {
						this._sContentDensityClass = "";
					} else if (!Device.support.touch) { // apply "compact" mode if touch is not supported
						this._sContentDensityClass = "sapUiSizeCompact";
					} else {
						// "cozy" in case of touch support; default for most sap.m controls, but needed for desktop-first controls like sap.ui.table.Table
						this._sContentDensityClass = "sapUiSizeCozy";
					}
				}
				return this._sContentDensityClass;
			},
			
			/**
			 * Configure Batch Groups for unique API calls
			 * 
			 */
			 _configureBatchGroups : function() {
			 	var sChngGroup	= this.batchGroup,
			 		oDataModel	= this.getModel();
			 	
			 	// Create change groups to centralize changes
				oDataModel.setChangeGroups({
					"HEADR": {
					    groupId: sChngGroup,
					    single: false
					  },
					"EVENT": {
					    groupId: sChngGroup,
					    single: false
					  },
					"FILES": {
					    groupId: sChngGroup,
					    single: false
					  },
					"ITEMS": {
					    groupId: sChngGroup,
					    single: false
					  },
					"VALID": {
					    groupId: sChngGroup,
					    single: false
					  },
					"VENDR": {
					    groupId: sChngGroup,
					    single: false
					  }
					}
				);

				//	Set Change groups as "deferred" to be triggered only on SubmitChanges
				oDataModel.setDeferredGroups( [sChngGroup] );
			 }
		});
	}
);