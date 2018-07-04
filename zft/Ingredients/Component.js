sap.ui.define([
	"sap/ui/core/UIComponent",
	"sap/ui/Device",
	"CatalogMat/model/models"
], function(UIComponent, Device, models) {
	"use strict";

	return UIComponent.extend("CatalogMat.Component", {

		metadata: {
			manifest: "json"
		},

		/**
		 * The component is initialized by UI5 automatically during the startup of the app and calls the init method once.
		 * @public
		 * @override
		 */
		init: function() {
			// call the base component's init function
			UIComponent.prototype.init.apply(this, arguments);
			
			jQuery.sap.registerModulePath( "images", "images/" ); 

			// set the device model
			this.setModel(models.createDeviceModel(), "device");
			
			// set the FLP model
			this.setModel(models.createFLPModel(), "FLP");

			// this.VHModelsInit();

			// create the views based on the url/hash
			this.getRouter().initialize();
			
			//	Set Service Size limit
			this.getModel( "VHService" ).setSizeLimit( 100000 );
		this.initModel();
		},
		
		initModel:function(){
			this.setModel( new sap.ui.model.json.JSONModel(), "VhHierarchy" );
			
			this.setModel( new sap.ui.model.json.JSONModel({	"EditOn" 	:	false,
																"delete" 	: 	"None",
																"buttonOn" 	: 	true ,
																"FileEdit"	:	false,
																"Status"	:	"",
																"FileDelete": 	"None",
																"TARAP" 	: "",
															    "DISTB" 	: "",
															    "MFRNM" 	: "",
															    "MAKTX" 	: "",
															    "TEMPB" 	: "",
															    "NTGEW" 	: "",
															    "VLCRN" 	: "",
															    "DCDTD" 	: "",
															    "KBETR" 	: "",
															    "MEINS" 	: "",
															    "AR2SF" 	: "",
															    "STATS" 	: "",
															    "RECIP" 	: "",
															    "RMATN" 	: "",
															    "Unit"		: true
																						}), "Edit" );
		
			var service =	this.getModel( "CatMatService" ),
				that	=	this,
				edit;
			
            service.read( "/VHAuthorizationsSet('ZFT_UI_MAT')" , {
				 success: function( oData ) {
				 	edit		=	that.getModel( "Edit" ).getData();
				 	edit.Create	=	oData.CREAT;
                    edit.Display=	oData.DISPL;
                    edit.Modif	=	oData.MODIF;
                    that.getModel( "Edit" ).setData( edit );
                    },
                error: function( error ) {
                     
                    }
                });
            service.read( "/VHAuthorizationsMPSet('ZFT_UI_MDT')" , {
				 success: function( oData ) {
				 	edit		=	that.getModel( "Edit" ).getData();
				 	edit.TARAP	=	oData.TARAP;
					edit.DISTB	=	oData.DISTB;
					edit.MFRNM	=	oData.MFRNM;
					edit.MAKTX	=	oData.MAKTX;
					edit.TEMPB	=	oData.TEMPB;
					edit.NTGEW	=	oData.NTGEW;
					edit.VLCRN	=	oData.VLCRN;
					edit.DCDTD	=	oData.DCDTD;
					edit.KBETR	=	oData.KBETR;
					edit.MEINS	=	oData.MEINS;
					edit.AR2SF	=	oData.AR2SF;
					edit.STATS	=	oData.STATS;
					edit.RECIP	=	oData.RECIP;
					edit.RMATN	=	oData.RMATN;
                    that.getModel( "Edit" ).setData( edit );
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
		}
	});
});