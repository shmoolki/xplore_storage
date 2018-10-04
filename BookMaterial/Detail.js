/*global location*/
sap.ui.define([
    "iae/controllerAdds/BaseController",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/routing/History",
    "iae/model/Formatter",
    "sap/m/MessageBox"
], function (
    BaseController,
    JSONModel,
    History,
    formatter, 
    MessageBox
) {
    "use strict";

    return BaseController.extend("iae.controller.Detail", {

        formatter	:	formatter,
        thisDetail	:	this,

        /* =========================================================== */
        /* lifecycle methods                                           */
        /* =========================================================== */

        /**
         * Called when the worklist controller is instantiated.
         * @public
         */
        onInit : function ( event ) {
            // Model used to manipulate control states. The chosen values make sure,
            // detail page is busy indication immediately so there is no break in
            // between the busy indication for loading the view's meta data
            var iOriginalBusyDelay,
                oViewModel	= new JSONModel({
                    busy : true,
                    delay : 0
                });
            
            
            
        
            // Store original busy indicator delay, so it can be restored later on
            iOriginalBusyDelay = this.getView().getBusyIndicatorDelay();
            this.setModel(oViewModel, "objectView");
            this.getOwnerComponent().getModel().metadataLoaded().then(function () {
                    // Restore original busy indicator delay for the object view
                    oViewModel.setProperty("/delay", iOriginalBusyDelay);
                }
            );
            this._oODataModel = this.getOwnerComponent().getModel();
            this._oResourceBundle = this.getResourceBundle();
            
            this.router 	= sap.ui.core.UIComponent.getRouterFor(this);
            this.router.attachRoutePatternMatched( this.handleRouting , this);
            // this.router.attachRouteMatched( this.afterRouting , this);

            var that	=	this;
            // Register the view with the message manager
            sap.ui.getCore().getMessageManager().registerObject(this.getView(), true);
            var oMessagesModel = sap.ui.getCore().getMessageManager().getMessageModel();
            this._oBinding = new sap.ui.model.Binding(oMessagesModel, "/", oMessagesModel.getContext("/"));
            this._oBinding.attachChange(function(oEvent) {
                var aMessages = oEvent.getSource().getModel().getData();
                for (var i = 0; i < aMessages.length; i++) {
                    if (aMessages[i].type === "Error" && !aMessages[i].technical) {
                        that._oViewModel.setProperty("/enableCreate", false);
                    }
                }
            });
            this.uploadFile = false;
            this.initModel();
            
        },
        
        handleRouting: function( oEvent ){
            var sObjectId	=	oEvent.getParameter("arguments").objectId,
                service		=	this.getModel();
            // this.byId("ObjectPageLayout").setSelectedSection("__section1");
            this.pageName	=	oEvent.getParameter("name");
            this.getView().unbindObject();
            switch ( this.pageName ) {
                case "Overview":
                    return;
                case "NouveauDevis":
                    // this.byId( "iconTabDetail" ).setSelectedKey( "infoGeneralTab" );
                    // this._onCreate();
                    this._ObjectId	=	"$";
                    var oContext = this._oODataModel.createEntry( "HEADRSet" , { groupId:"xcChgGrp" });
                    this.getView().setBindingContext(oContext);

                    this.getModel("Process").setData({
                    lanes:
                     [
                        {id: "0"	, icon: "sap-icon://it-host",			label: this._oResourceBundle.getText( "DEVIS" ), 		position: 0, state:[]	},				           
                        {id: "1"	, icon: "sap-icon://accept",			label: this._oResourceBundle.getText( "VALIDATION" ),	position: 1, state:[]	},
                        {id: "2"	, icon: "sap-icon://cart-approval",		label: this._oResourceBundle.getText( "RECEPTION" ),	position: 2, state:[]	},
                        {id: "3"	, icon: "sap-icon://sales-quote",		label: this._oResourceBundle.getText( "FACTURE" ),		position: 3, state:[]	},
                        {id: "4"	, icon: "sap-icon://paid-leave",		label: this._oResourceBundle.getText( "PAIEMENT" ),		position: 4, state:[]	}
                     ]
                   });
                    this.getModel("recetteTable").setData([]);
                    this.getModel("postTable").setData({items:[]});
                    this.getModel("FournisseurTable").setData([]);
                    this.getModel("docTable").setData([]);
                    this.getModel("ValidationTable").setData({});
                    this.getModel("journalTable").setData({});
                    this.getModel("UploadImage").setData({});
                    this.getModel("UploadFile").setData({});
                    this.onEdit();
                    this.getModel( "Edit" ).setProperty( "/Detail", false );
                    var path		= this.getView().getBindingContext().getPath();
                        
                    this._oODataModel.setProperty( path + "/WERKS" , this.getView().getModel( "Site" ).getProperty( "/WERKS" ) );

                    break;
                case "Detail":

                    this.getAllModels( sObjectId, service );
                    break;
            }
            this.getView().rerender();
        },
        
        getAllModels: function( sObjectId, service ){
            this._ObjectId	=	sObjectId;
            this.readModel( this.getModel());
            service.metadataLoaded().then( function() {
                var sObjectPath = this.getModel().createKey("HEADRSet", {
                    DAMNB :  sObjectId
                });
                this._bindView("/" + sObjectPath);
                this.sObjectPath = sObjectPath;
            
            }.bind(this));	
            this.getView().rerender();
        },
        
        readModel: function( service ){
            var that	=	this,
                postModel;
            service.read( "/HEADRSet('" + this._ObjectId + "')", {
                success: function ( oData ) {
                    that.setProcessFlow( oData );
                    that.byId( "processflow" ).setZoomLevel( "Three" );
                },
                error: function( err ){
                    sap.m.MessageToast.show( "ERROR" );
                }
            } );
            
            service.read( "/HEADRSet('" + this._ObjectId + "')/ITEMSSet()", {
                success: function ( oData ) {
                    postModel	=	oData.results;
                    that.showValidButton( postModel );
                    that.treeModel( postModel );
                    that.getView().byId("ITable").collapseAll();
                },
                error: function( err ){
                    sap.m.MessageToast.show( "ERROR" );
                }
            } );
            
            service.read( "/HEADRSet('" + this._ObjectId + "')/FILESSet()", {
                success: function ( oData ) {
                    that.getView().getModel( "FileTable" ).setData( oData.results );
                },
                error: function( err ){
                    sap.m.MessageToast.show( "ERROR" );
                }
            } );
            
            
            service.read( "/HEADRSet('" + this._ObjectId + "')/VALIDSet()", {
                success: function ( oData ) {
                    that.getView().getModel( "ValidationTable" ).setData( oData.results );
                },
                error: function( err ){
                    sap.m.MessageToast.show( "ERROR" );
                }
            } );
            
            service.read( "/HEADRSet('" + this._ObjectId + "')/EVENTSet()", {
                success: function ( oData ) {
                    that.getModel( "journalTable" ).setData( oData.results );
                },
                error: function( err ){
                    sap.m.MessageToast.show( "ERROR" );
                }
            } );
            
        },
        
        _onCreate: function(oEvent) {
            var oContext = this._oODataModel.createEntry("DetailSet");
            this.getView().setBindingContext(oContext);
        },
        
        showValidButton: function( model ){
            var edit	=	this.getView().getModel( "Edit" ),
                check	=	true;
            for ( var i=0; i<model.length; i++ ) {
                if( model[i].NETPR === "" ){
                    edit.setProperty( "/ButtonValidation",false );
                    check	=	false;
                }
            }       
            if( check ){
                edit.setProperty( "/ButtonValidation", true );
            }
        },
        
        setProcessFlow: function( object ){
            var model			=	this.getView().getModel( "Process" ).getData(),
                neutral			=	{state:sap.suite.ui.commons.ProcessFlowNodeState.Neutral, value: 0},
                positive		=	{state:sap.suite.ui.commons.ProcessFlowNodeState.Positive, value: 0},
                critical		=	{state:sap.suite.ui.commons.ProcessFlowNodeState.Negative, value: 0},
                data			=	object,
                status			=	[];
            if( model.length === 0 ){
                this._processModel = new JSONModel({
                lanes:
                    [
                        {id: "0", icon: "sap-icon://it-host",			label: this._oResourceBundle.getText( "DEVIS" ), 		position: 0, state:[]	},				           
                        {id: "1", icon: "sap-icon://accept",			label: this._oResourceBundle.getText( "VALIDATION" ),	position: 1, state:[]	},
                        {id: "2", icon: "sap-icon://cart-approval",		label: this._oResourceBundle.getText( "RECEPTION" ),	position: 2, state:[]	},
                        {id: "3", icon: "sap-icon://sales-quote",		label: this._oResourceBundle.getText( "FACTURE" ),		position: 3, state:[]	},
                        {id: "4", icon: "sap-icon://paid-leave",		label: this._oResourceBundle.getText( "PAIEMENT" ),		position: 4, state:[]	}
                     ]
                   });
                this.setModel(this._processModel, "Process");
                model			=	this.getView().getModel( "Process" ).getData();
            }
            for (var i = 1;  i < 6 ;  i++) {
                if( data[ "P" + i + "_PO" ] > 0 || data[ "P" + i + "_PL" ] > 0 || data[ "P" + i + "_NE" ] > 0 ){
                    if( data[ "P" + i + "_PO" ] > 0 ){
                        positive.value = data[ "P" + i + "_PO" ];
                    }
                    if( data[ "P" + i + "_PL" ] > 0 ){
                        neutral.value = data[ "P" + i + "_PL" ];
                    }
                    if( data[ "P" + i + "_NE" ] > 0 ){
                        critical.value = data[ "P" + i + "_NE" ];
                    }
                    model.lanes[i - 1].state.push(Object.assign({}, positive));
                    model.lanes[i - 1].state.push(Object.assign({}, neutral));
                    model.lanes[i - 1].state.push(Object.assign({}, critical));
                    positive.value	=	0;
                    neutral.value	=	0;
                    critical.value	=	0;
                }
            }
            this.getView().getModel( "Process" ).setData( model );
            this.byId( "processflow" ).rerender();
        },
        
        initModel: function(){
            this._oViewModel = new JSONModel({
                    enableCreate: false,
                    delay		:	0,
                    busy		:	false,
                    buttonOn	:	true,
                    deleteM		:	"None",
                    viewTitle	:	"",
                    NonRef		:	false,
                    EditOn		:	false,
                    Litige		:	false,
                    Detail		:	false,
                    ButtonValidation : false,
                    removeRecipe:	false,
                    selectMode	:	"None",
                    enabledSave	:	false,
                    uploadFile	:	false
                });
            this.setModel(this._oViewModel, "Edit");
            this._processModel = new JSONModel({
                   lanes:
                     [
                        {id: "0", icon: "sap-icon://it-host",			label: this._oResourceBundle.getText( "DEVIS" ), 		position: 0, state:[]	},				           
                        {id: "1", icon: "sap-icon://accept",			label: this._oResourceBundle.getText( "VALIDATION" ),	position: 1, state:[]	},
                        {id: "2", icon: "sap-icon://cart-approval",		label: this._oResourceBundle.getText( "RECEPTION" ),	position: 2, state:[]	},
                        {id: "3", icon: "sap-icon://sales-quote",		label: this._oResourceBundle.getText( "FACTURE" ),		position: 3, state:[]	},
                        {id: "4", icon: "sap-icon://paid-leave",		label: this._oResourceBundle.getText( "PAIEMENT" ),		position: 4, state:[]	}
                     ]
                   });
            
            this.setModel(this._processModel, "Process");
            
            this.setModel( new JSONModel(), "recetteTable" );
            
            this.setModel( new JSONModel(), "postTable" );
            
            this.setModel( new JSONModel(), "FournisseurTable" );
            
            this.setModel( new JSONModel(), "docTable" );
            
            this.setModel( new JSONModel(), "ValidationTable" );
            
            this.setModel( new JSONModel(), "journalTable" );
            
            this.setModel( new JSONModel(), "UploadImage" );
            
            this.setModel( new JSONModel(), "UploadFile" );
            
            this.setModel( new JSONModel(), "FileTable" );
        },
        
        treeModel: function(data) {
            if (!data.items) {
                var articleTab = data.reduce(function(result, item) {
                    if ( !result[item.ANFPS] ) {
                        item.ACTVT	=	"";
                        result[item.ANFPS] = item;
                        result[item.ANFPS].items = [];
                    }
                    if( item.HEADR !== "X" ){
                        item.ACTVT	=	"";
                        result[item.ANFPS].items.push(item);
                    }
                    return result;
                }, {})
                var data = {};
                data.items	=	[];
    
                for (var key in articleTab) {
                    data.items.push(articleTab[key]);
                }
            }
            
            this.getView().getModel( "postTable" ).setData( data );
    
        },

        /* =========================================================== */
        /* event handlers                                              */
        /* =========================================================== */

        /**
         * Event handler when the share in JAM button has been clicked
         * @public
         */
        onShareInJamPress : function () {
            var oViewModel = this.getModel("objectView"),
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
        
        addFilePopOver: function (oEvent) {
    
            // create popover
            if (! this._oPopover) {
                this._oPopover = sap.ui.xmlfragment("iae.fragment.addFilePopOver", this);
                this.getView().addDependent(this._oPopover);
            }
    
            var oButton = oEvent.getSource();
            jQuery.sap.delayedCall(0, this, function () {
                this._oPopover.openBy(oButton);
            });
        },
        closePopOver: function(){
            var imgModel	=	this.getView().getModel( "UploadImage" );
            imgModel.setProperty( "/URL", "" );
            imgModel.setProperty( "/description", "" );
            this._oPopover.close();
        },
        
        filePopover: function (oEvent) {
    
            // create popover
            if (! this._oFilePopover) {
                this._oFilePopover = sap.ui.xmlfragment("iae.fragment.FileTabPopUp", this);
                this.getView().addDependent(this._oFilePopover);
            }
            var table	=	this._oFilePopover.getContent()[0].getContent()[0],
                path	=	oEvent.getSource().getParent().getBindingContext("postTable").getPath(),
                row 	=	this.getView().getModel( "postTable" ).getProperty( path ),
                data	=	this.getModel().getProperty( "/HEADRSet('" + this._ObjectId + "')" ),
                edit	=	this.getView().getModel( "Edit" ),
                filters	=	[];
                
            if( row.HEADR === "X"){
                edit.setProperty( "/uploadFile", true );
                table.setMode("Delete");
            }else{
                if( data.P3_NE !== 0 || data.P3_PL !== 0 || data.P3_PO !== 0 ){
                    edit.setProperty( "/uploadFile", false );
                    table.setMode("None");
                }else{
                    edit.setProperty( "/uploadFile", true );
                    table.setMode("Delete");
                }
            }
        
            filters.push( new sap.ui.model.Filter( "EBELN" , sap.ui.model.FilterOperator.EQ , row.EBELN ) );
            table.getBinding( "items" ).filter( new sap.ui.model.Filter( filters, true) );
            this._oFilePopover.path	=	path;
                
            this._oFilePopover.open();
        },
        closeFilePopOver: function(){
            this._oFilePopover.close();
        },
        fournisseurSelected: function( event ){
            var selectedModel	=	this.getModel( "FournisseurTable" ).getData(),
                pModel			=	this.getView().getModel( "postTable" ).getData(),
                path			=	Number( this.matnrPath.split( "/items/" )[1] ),
                exist			=	false;
            
            
            for (var i=0; i<selectedModel.length; i++) {
                if( selectedModel[i].SELEC ){
                    for (var j=0;pModel.items[path].items && j < pModel.items[path].items.length; j++) {
                        if( pModel.items[path].items[j].LIFNR	===	 selectedModel[i].LIFNR ){
                            exist	=	true;
                            break;
                        }
                    }
                    if( !exist ){
                        var	line        	=   {};
                        line.DAMNB	=	selectedModel[i].DAMNB;
                        line.MATNR	=	selectedModel[i].MATNR;
                        line.LIFNR	=	selectedModel[i].LIFNR;
                        line.NAME1	=	selectedModel[i].NAME1;
                        line.EMAIL	=	selectedModel[i].EMAIL;
                        line.HEADR	=	"";
                        line.ANFPS	=	this.fournisseurData.ANFPS;
                        line.MENGE	=	this.fournisseurData.MENGE;
                        line.GR_KO	=	false;
                        line.GR_OK	=	false;
                        line.DOCUM	=	false;
                        line.ACTVT	=	"N";
                        line.deletable = 'OK';
                        if( !pModel.items[path].items ){
                            pModel.items[path].items	=	[];
                        }
                        pModel.items[path].items.push(line);
                    }
                    exist		=	false;
                }
            }
            
            this.getView().getModel( "postTable" ).setData( pModel );
            this._oFournisseurPopover.close();
            
        },
        
        radioButtonFournisseur: function ( event ){
            var source		=	event.getSource().getParent(),
                path		=	source.getBindingContext( "postTable" ).getPath(),
                model		=	this.getView().getModel( "postTable" ),
                selectedRow	=	model.getProperty( path ),
                line		=	path.split("/")[2],
                header		=	"/items/" + line;
            if( selectedRow.ANFNR &&  selectedRow.NETPR 
                && selectedRow.ANFNR	!== "" &&  selectedRow.NETPR	!== "" ){
                model.setProperty( header + "/ANFNR", selectedRow.ANFNR );
                model.setProperty( header + "/NAME1", selectedRow.NAME1 );
                model.setProperty( header + "/LIFNR", selectedRow.LIFNR );
                model.setProperty( header + "/EMAIL", selectedRow.EMAIL );
                model.setProperty( header + "/MENGE", selectedRow.MENGE );
                model.setProperty( header + "/NETPR", selectedRow.NETPR );
                model.setProperty( header + "/EBELN", selectedRow.EBELN );
                model.setProperty( header + "/EBELP", selectedRow.EBELP );
                this.GridtableUpdate(event);
            }else{
                var that		=	this,
                    dialog		=	new sap.m.Dialog({
                        title		: that._oResourceBundle.getText("ERROR_DATA"),
                        type		: 'Message',
                        content		: new sap.m.Text({ text: that._oResourceBundle.getText("DEVIS_CHECK") }),
                        beginButton	: new sap.m.Button({
                            text	:	that._oResourceBundle.getText("CLOSE") ,
                            press	: function () {
                                // Update the message to server model
                                model.setProperty( path + "/SELEC", false );
                                dialog.close();
                                return;
                            }
                        }),
                        afterClose: function () {
                            dialog.destroy();
                            that.getView().setBusy( false );
                        }
                    });
                dialog.open();
            }
            
        },
        
        fournisseurPopover: function (oEvent) {
            if( this.getView().getModel( "Edit" ).getProperty( "/EditOn" ) ){
                var that			=	this,
                    source			=	oEvent.getSource(),
                    path			=	source.getParent().getBindingContext("postTable").getPath(),
                    fournisseurData	=	this.getView().getModel("postTable").getProperty( path ),
                    model			=	this.getView().getModel( "FournisseurTable" ),
                    temp			=	[],
                    filter			=	[];
                    
                this.getView().getModel( "Edit" ).setProperty( "/NonRef", false );
                filter.push(new sap.ui.model.Filter({ 
                                        path 	: 	"MATNR",
                                        operator: 	sap.ui.model.FilterOperator.EQ,  
                                        value1 	: 	fournisseurData.MATNR
                                    }));
                if( this._ObjectId !== "$" ){
                    filter.push(new sap.ui.model.Filter({ 
                                            path 	: 	"DAMNB",
                                            operator: 	sap.ui.model.FilterOperator.EQ,  
                                            value1 	: 	this._ObjectId
                                        }));
                }
                this.fournisseurData	=	fournisseurData;
                this.matnrPath			=	path;
                this.getModel().read( "/VENDRSet()" , {
                    filters: filter,
                    success: function ( oData ) {
                        for (var i=0; i<oData.results.length; i++) {
                            if(	oData.results[i].LIFNR.includes( "NONREF" ) ){
                                that.getModel( "Edit" ).setProperty( "/NonRef", true );
                            }else{
                                oData.results[i].editable = false;
                                oData.results[i].checkEditable = oData.results[i].SELEC;
                                temp.push( oData.results[i] );
                            }
                        }	
                        model.setData( temp );	
                    },
                    error: function( err ){
                        sap.m.MessageToast.show( that._oResourceBundle.getText( "ERROR" ) );
                    }
                });
                // create popover
                if (! this._oFournisseurPopover) {
                    this._oFournisseurPopover = sap.ui.xmlfragment("iae.fragment.FournisseurList", this);
                    this.getView().addDependent(this._oFournisseurPopover);
                }
        
                var oButton = oEvent.getSource();
                jQuery.sap.delayedCall(0, this, function () {
                    this._oFournisseurPopover.openBy(oButton);
                });
            }
            
        },
        addFournisseur: function(){
            var model	=	this.getView().getModel( "FournisseurTable" ).getData(),
                line	=	{	MATNR			:	this.fournisseurData.MATNR,
                                LIFNR			:	"",
                                NAME1			:	"",
                                EMAIL			:	"",
                                SELEC			:	false,
                                editable		:	true,
                                checkEditable	:	false
                };
                model.push(line);
            this.getView().getModel( "FournisseurTable" ).setData( model );
        },
        closeFournisseurPopOver: function(){
            this._oFournisseurPopover.close();
        },

        /**
         * Event handler  for navigating back.
         * It there is a history entry or an previous app-to-app navigation we go one step back in the browser history
         * If not, it will replace the current entry of the browser history with the worklist route.
         * @public
         */
        onNavBack : function() {
            var edit				=	this.getView().getModel( "Edit" ).getProperty( "/EditOn" ),
                msgArea	=	this.byId("msgArea");
            msgArea.removeAllItems();
            this.getView().getModel( "Process" ).setData({
                    lanes:
                     [
                        {id: "0"	, icon: "sap-icon://it-host",			label: this._oResourceBundle.getText( "DEVIS" ), 		position: 0, state:[]	},				           
                        {id: "1"	, icon: "sap-icon://accept",			label: this._oResourceBundle.getText( "VALIDATION" ),	position: 1, state:[]	},
                        {id: "2"	, icon: "sap-icon://cart-approval",		label: this._oResourceBundle.getText( "RECEPTION" ),	position: 2, state:[]	},
                        {id: "3"	, icon: "sap-icon://sales-quote",		label: this._oResourceBundle.getText( "FACTURE" ),		position: 3, state:[]	},
                        {id: "4"	, icon: "sap-icon://paid-leave",		label: this._oResourceBundle.getText( "PAIEMENT" ),		position: 4, state:[]	}
                     ]
                   });
            
             if( edit ){ //&& this.pageName	===	"Detail" 
                this.onCancel( "NavBack" );
            }
            else {
                this.router.navTo("Overview", {}, true);
            }
        },

        /* =========================================================== */
        /* internal methods                                            */
        /* =========================================================== */

        _setModelData: function( service ){
            var postModel		=	this.getView().getModel( "postTable" ),
                validModel		=	this.getView().getModel( "ValidationTable" ),
                filter			=	new sap.ui.model.Filter({ 
                                        path 	: 	"DAMNB",
                                        operator: 	sap.ui.model.FilterOperator.EQ,  
                                        value1 	: 	this._ObjectId
                                    });
            
            this._getModelData( service, filter, postModel, "/ITEMSSet()" );
            this._getModelData( service, filter, validModel, "/VALIDSet()" );
        },
        
        _getModelData: function( service, filter, model, path ){
            var that	=	this;
            service.read( path , {
                filters: [ filter ],
                success: function ( oData ) {
                    $.each(oData.results, function( index, value ) {
                        value.ACTVT	=	"";
                    });	
                    model.setData( oData.results );	
                },
                error: function( err ){
                    sap.m.MessageToast.show( that._oResourceBundle.getText( "ERROR" ) );
                }
            });
        },
        
        _validateSaveEnablement: function(){
            var edit	=	this.getModel( "Edit" ),
                date	=	this.byId( "idDate" ).getValue(),
                descr	=	this.byId( "idDescription" ).getValue();
            
            if( date !== "" && descr !== "" ){
                edit.setProperty( "/enabledSave", true );
            }else{
                edit.setProperty( "/enabledSave", false );
            }
        },

        /**
         * Binds the view to the object path.
         * @function
         * @param {string} sObjectPath path to the object to be bound
         * @private
         */
        _bindView : function (sObjectPath) {
            var oViewModel = this.getModel("objectView"),
                oDataModel = this.getModel();

            this.getView().bindElement({
                path: sObjectPath,
                events: {
                    // change: this._onBindingChange.bind(this),
                    dataRequested: function () {
                        oDataModel.metadataLoaded().then(function () {
                            // Busy indicator on view should only be set if metadata is loaded,
                            // otherwise there may be two busy indications next to each other on the
                            // screen. This happens because route matched handler already calls '_bindView'
                            // while metadata is loaded.
                            oViewModel.setProperty("/busy", true);
                        });
                    },
                    dataReceived: function () {
                        oViewModel.setProperty("/busy", false);
                    }
                }
            });
        },

        _onBindingChange : function () {
            var oView = this.getView(),
                oViewModel = this.getModel("objectView"),
                oElementBinding = oView.getElementBinding();

            // No data for the binding
            // if (!oElementBinding.getBoundContext()) {
            // 	this.getRouter().getTargets().display("objectNotFound");
            // 	return;
            // }

            var oResourceBundle = this.getResourceBundle(),
                oObject = oView.getBindingContext().getObject(),
                sObjectId = oObject.CDNUM,
                sObjectName = oObject.DESCR;

            // Everything went fine.
            oViewModel.setProperty("/busy", false);
            oViewModel.setProperty("/saveAsTileTitle", oResourceBundle.getText("saveAsTileTitle", [sObjectName]));
            oViewModel.setProperty("/shareOnJamTitle", sObjectName);
            oViewModel.setProperty("/shareSendEmailSubject",
            oResourceBundle.getText("shareSendEmailObjectSubject", [sObjectId]));
            oViewModel.setProperty("/shareSendEmailMessage",
            oResourceBundle.getText("shareSendEmailObjectMessage", [sObjectName, sObjectId, location.href]));
        },
        
        /**
         * Initialistion of newproduct popUp
         */
        NewPostePress: function(){
                if( !this._NewPoste ){
                this._NewPoste = sap.ui.xmlfragment( "iae.fragment.PosteList", this);
                this.getView().addDependent(this._NewPoste);
            }
            var	filters	=	[];
            filters.push( new sap.ui.model.Filter( "WERKS" , sap.ui.model.FilterOperator.Contains , this.byId( "selectStore" ).getSelectedKey()  ) );
            this._NewPoste.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
             this._NewPoste.open();
        },
        
        /**
         * Generic function that do filter on all dialog list of detail view
         * the function take the value of the search field
         * the name field and number of the thing we search
         * and the binding field
         */
        handleDialogSearch: function( value, description, binding ) {
            var filter 	= new sap.ui.model.Filter( description, sap.ui.model.FilterOperator.EQ, value),
                allFilter 	= new sap.ui.model.Filter([filter], false);
            binding.filter(allFilter);
        },
        
        
        deleteLine:function( event ){
            var source		=	event.getSource(),
                path		=	event.getParameter("listItem").getBindingContextPath(),
                modelName	=	source.getBindingInfo("items").model,
                model		=	this.getModel( modelName );
            model.setProperty( path + "/ACTVT" ,"D");
            source.getBinding("items").filter([new sap.ui.model.Filter( "ACTVT" , sap.ui.model.FilterOperator.NE , "D" )]);
        },
        
        tableUpdate:function( event ){
            var source		=	event.getSource(),
                object		=	source.getMetadata().getName(),
                path		=	source.getParent().getBindingContextPath(),
                table		=	source.getParent().getParent();
                this.UpdateTableAction( table, path, object, "items" );
        },
        
        GridtableUpdate:function( event ){
            var source		=	event.getSource(),
                object		=	source.getMetadata().getName(),
                field		=	false,
                parent;
            if( object.includes( "Input" ) ){
                parent		=	source.getParent();
                field		=	source.getBindingInfo("value").binding.getPath();
            }else{
                parent		=	source.getParent().getParent();
            }
            
            var	index		=	parent.getIndex(),
                table		=	parent.getParent(),
                path		=	table.getContextByIndex( index ).getPath(),
                modelName	=	table.getBindingInfo( "rows" ).model,
                model		=	this.getModel( modelName );
            if( field === "NETPR" && model.getProperty( path + "/SELEC") ){
                this.UpdateHeader( model, path, source.getValue(),  table , object );
            }
            this.UpdateTableAction( table, path, object, "rows" );
        },
        UpdateHeader:function( model , path , value , table , object){
            var temp		=	path.split( "/" ),
                headerPath	=	"/" + temp[1] + "/" + temp[2];
            model.setProperty( headerPath + "/NETPR", value );
            this.UpdateTableAction( table, headerPath, object, "rows" );
        },
        UpdateTableAction:function( table, path, object, line ){
            var modelName	=	table.getBindingInfo( line ).model,
                model		=	this.getModel( modelName );
            if( model.getProperty( path + "/ACTVT" ) === "U" && object.includes( "CheckBox" ) ){
                model.setProperty( path + "/ACTVT" ,"");
            }else if( model.getProperty( path + "/ACTVT" ) === "N" && object.includes( "CheckBox" )){
                model.setProperty( path + "/ACTVT" ,"");
            }else if( model.getProperty( path + "/ACTVT" ) !== "N"){
                model.setProperty( path + "/ACTVT" ,"N");
            }
        },
        
        showRemoveButton: function( event ){
            var source		=	event.getSource(),
                selected	=	source.getSelectedIndex(),
                content		=	source.getAggregation("toolbar").getAggregation("content"),
                button		=	content[ content.length - 2 ];
            if( selected < 0 ){
                button.setVisible( false );
                return;
            }
            var path		=	event.getSource().getContextByIndex( selected ).getPath(),
                hdr			=	this.getView().getModel( "postTable" ).getProperty( path + "/HEADR" ),
                edit		=	this.getModel( "Edit" );
                
            if( selected	!== -1 && edit.getProperty( "/EditOn" ) && hdr === "X" ){
                button.setVisible( true );
            }else{
                button.setVisible( false );
            }
        },
        deletePost: function( event ){
            var source		=	event.getSource(),
                table		=	source.getParent().getParent(),
                modelTable  =   table.getBindingInfo("rows").model,
                index		=	table.getSelectedIndex(),
                path		=	table.getContextByIndex( index ).getPath(),
                line		=	this.getView().getModel( modelTable ).getProperty( path );
            line.ACTVT		=	"D";
            if( line.items ){
                for (var i=0; i<line.items.length; i++) {
                    line.items[i].ACTVT	=	"D";
                }
            }
            this.getView().getModel( modelTable ).setProperty( path, line );
            table.getBinding("rows").filter([new sap.ui.model.Filter( "ACTVT" , sap.ui.model.FilterOperator.NE , "D" )]);
            table.setSelectedIndex(-1);
        },
        
        /**
         * Search function of Recipe dialog
         */
        handleRecipeSearch: function(oEvent) {
            var sValue 		= oEvent.getParameter("value"),
                oBinding 	= oEvent.getSource().getBinding("items");
            
            this.handleDialogSearch( sValue, "TITRE", oBinding);
        },
        checkODataChange: function( model, mode ){
            for(var i=0; i<model.length; i++) {
                if( model[i].ACTVT !== "" ){
                    if( mode !== "Cancel" ){
                        this.oDataChange( model );
                    }
                    return true;
                }
            }
            return false;
        },
        oDataChange: function( model ){
            var oModel	=	this._oODataModel,
                param	=	{"groupId": this.getOwnerComponent().batchGroup },
                check	=	true;
            
            for( var i = 0 ; i<model.length ; i++) {
                switch ( model[i].ACTVT ) {
                    case "D":
                        delete model[i]["ACTVT"];
                        oModel.remove( this.setKey( model[ i ], "D" ) , param );
                        break;
                    case "U":
                        delete model[i]["ACTVT"];
                        oModel.update( this.setKey( model[ i ], "U" ), model[i] , param );
                        
                        break;
                    case "N":
                        //	Call Create API (deferred)
                        delete model[i]["ACTVT"];
                        param.properties = model[i];
                        oModel.createEntry( this.setKey( model[ i ], "N" ), param );
                        break;
                    case "":
                        delete model[i]["ACTVT"];
                        oModel.update( this.setKey( model[ i ], "U" ), model[i] , param );
                        
                        break;
                }
            }	
        },
        setKey:function( model, type ){
            if( type === "N" ){
                return "/ITEMSSet()";
            }else{
                return "/ITEMSSet(DAMNB='" + this._ObjectId +"',HEADR='" + model.HEADR + "',ANFPS='" + model.ANFPS + "',EBELN='" + model.EBELN + "')";
            }
        },
        
        restoreModel: function( model ){
            var data	=	[];
            
            if( !model ) {
                return data;
            }
            
            for (var i=0; i<model.length; i++) {
                if( model[i].items ){
                    for (var j=0; j<model[i].items.length; j++) {
                        delete model[i].items[j]["__metadata"];
                        // delete model[i].items[j]["__proto__"];
                        data.push( model[i].items[j] );
                    }
                }
                delete model[i]["__metadata"];
                // delete model[i].items[j]["__proto__"];
                delete model[i]["items"];
                data.push( model[i] );
            }
            return data;
        },
        
        
        /**
         * Event handler (attached declaratively) for the view save button. Saves the changes added by the user. 
         * @function
         * @public
         */
        onSave: function() {
            var that			=	this,
                oModel			=	this.getModel(),
                path			=	this.getView().getBindingContext().getPath(),
                data			=	oModel.getProperty( path );
            
            
            // if( !data.EINDT || data.EINDT === "" || 
            // 	!data.HDTXT || data.HDTXT === "" || 
            // 	!data.FNAME || data.FNAME === "" || 
            // 	!data.LNAME || data.LNAME === "" || 
            // 	!data.AGAPP || data.AGAPP === "" ){
            // 	var fields = "";
            // 	if( data.EINDT === "" ){
            // 		fields += "\n - " + that._oResourceBundle.getText("DATE_LVR_PRVL");
            // 	}
            // 	if( data.HDTXT === "" ){
            // 		fields += "\n - " + that._oResourceBundle.getText("TEXTE_ENTETE");
            // 	}
            // 	if( data.FNAME === "" ){
            // 		fields += "\n - " + that._oResourceBundle.getText("FNAME");
            // 	}
            // 	if( data.LNAME === "" ){
            // 		fields += "\n - " + that._oResourceBundle.getText("LNAME");
            // 	}
            // 	if( data.AGAPP === "" ){
            // 		fields += "\n - " + that._oResourceBundle.getText("AGE_APAREIL");
            // 	}
            if(!that.checkMandatoryField()){
                var dialog		=	new sap.m.Dialog({
                    title: that._oResourceBundle.getText("ERROR_DATA"),
                    type: 'Message',
                    content: new sap.m.Text({ text: that._oResourceBundle.getText("REQUIRED_FIELD") }),
        
                        beginButton: new sap.m.Button({
                                text:	that._oResourceBundle.getText("CLOSE") ,
                                press: function () {
                                    // Update the message to server model
                                    dialog.close();
                                    return;
                                }
                            }),
                            afterClose: function () {
                                
                                dialog.destroy();
                                that.getView().setBusy( false );
                            }
                        });
            dialog.open();
            }
            else{
                var 	prestationModel	=	this.restoreModel( this.getModel( "postTable" ).getData().items ),
                        pFlag			=	this.checkODataChange(prestationModel, "" );
                if( this.pageName	===	"NouveauDevis" ){
                    this.byId( "objectHeader" ).setObjectTitle("$");
                }
        
                // abort if the  model has not been changed
                if (!oModel.hasPendingChanges() && !this.uploadFile && !pFlag) {
                    MessageBox.information(
                        that._oResourceBundle.getText("noChangesMessage"), {
                            id: "noChangesInfoMessageBox",
                            styleClass: that.getOwnerComponent().getContentDensityClass()
                        }
                    );
                    return;
                }else{
                    this.getModel().setProperty( "/HEADRSet('" + this._ObjectId + "')/UPDFL" , true );
                }
                
            
                this.getModel("appView").setProperty("/busy", true);
                
                oModel.submitChanges({
                    success: function( data ) {
                        var check			=	true,
                            damnb;
                        if( that.pageName === "NouveauDevis" ){
                            that.getModel("appView").setProperty("/busy", false);
                            damnb	=	data.__batchResponses[0].__changeResponses[0].data.DAMNB;
                            that._ObjectId		=	damnb;
                            that.pageName = "Detail";
                        }
                        oModel.refresh();
                        if (that._checkIfBatchRequestSucceeded(check) ) {
                            that.messageText	=	that._oResourceBundle.getText( "appDescription" ) + " " + that._ObjectId + " ";
                            if(  that.pageName === "NouveauDevis" ){
                                that.messageText = that.messageText + that._oResourceBundle.getText( "CSUCCESS" );
                            }else{
                                that.messageText = that.messageText + that._oResourceBundle.getText( "MSUCCESS" );
                            }
                            that.onEdit();
                            that.getModel("appView").setProperty("/busy", false);
                            that._fnUpdateSuccess();
                        } else {
                            that._fnEntityCreationFailed();
                            // MessageBox.error(that._oResourceBundle.getText("updateError"));
                            that.getModel("appView").setProperty("/busy", false);
                        }
                    },
                    error: function( error ) {
                        that.getModel("appView").setProperty("/busy", false);
                    }
                });
            }
        },
        
        /**
         * Gets the form fields
         * @param {sap.ui.layout.form} oSimpleForm the form in the view.
         * @private
         */
        _getFormFields: function(oSimpleForm) {
            var aControls = [];
            var aFormContent = oSimpleForm.getContent();
            var sControlType;
            for (var i = 0; i < aFormContent.length; i++) {
                sControlType = aFormContent[i].getMetadata().getName();
                if (sControlType === "sap.m.Input" || sControlType === "sap.m.DatePicker") {
                    aControls.push({
                        control: aFormContent[i],
                        required: aFormContent[i - 1].getRequired && aFormContent[i - 1].getRequired()
                    });
                }
            }
            return aControls;
        },
        
        /**
         * Checks if there is any wrong inputs that can not be saved.
         * @private
         */

        _checkForErrorMessages: function() {
            var aMessages = this._oBinding.oModel.oData;
            if (aMessages.length > 0) {
                var bEnableCreate = true;
                for (var i = 0; i < aMessages.length; i++) {
                    if (aMessages[i].type === "Error" && !aMessages[i].technical) {
                        bEnableCreate = false;
                        break;
                    }
                }
                this._oViewModel.setProperty("/enableCreate", bEnableCreate);
            } else {
                this._oViewModel.setProperty("/enableCreate", true);
            }
        },
        
        _checkIfBatchRequestSucceeded: function(oEvent) {
            if (oEvent) {
                return true;
            } else {
                return false;
            }
        },
        _fnUpdateSuccess: function() {
            this.getModel("appView").setProperty("/busy", false);
            this.getModel().refresh();
            // this.getView().unbindObject();
            this.getAllModels( this._ObjectId, this.getModel() );
            var msgArea	=	this.byId("msgArea"),
                oMsgStrip = new sap.m.MessageStrip({	text: 				this.messageText,
                                                        showCloseButton: 	true,
                                                        showIcon: 			true,
                                                        type: 				"Success"
                                                    });
            msgArea.addItem( oMsgStrip );
        },

        /**
         * Handles the success of creating an object
         *@param {object} oData the response of the save action
         * @private
         */
        _fnEntityCreated: function(oData) {
            this.getRouter().getTargets().display("object");
            var msgArea	=	this.byId("msgArea"),
            oMsgStrip = new sap.m.MessageStrip({	text: 				this._oResourceBundle.getText( "worklistViewTitle" ) + " " + this._ObjectId + " " + this._oResourceBundle.getText( "CSUCCESS" ),
                                                    showCloseButton: 	true,
                                                    showIcon: 			true,
                                                    type: 				"Success"
                                                });
            msgArea.addItem( oMsgStrip );
        },

        /**
         * Handles the failure of creating/updating an object
         * @private
         */
        _fnEntityCreationFailed: function() {
            this.getModel("appView").setProperty("/busy", false);
            var msgArea	=	this.byId("msgArea"),
            oMsgStrip = new sap.m.MessageStrip({	text: 				this._oResourceBundle.getText( "errorText" ),
                                                    showCloseButton: 	true,
                                                    showIcon: 			true,
                                                    type: 				"Error"
                                                });
            msgArea.addItem( oMsgStrip );
        },
        
        onEdit: function( event ){
            var edit		=	this.getView().getModel( "Edit" ),
                buttonOn	=	edit.getProperty( "/buttonOn" ),
                msgArea		=	this.byId("msgArea"),
                editOn		=	edit.getProperty( "/EditOn" ),
                oTreeTable	=	this.getView().byId("ITable");
            edit.setProperty( "/buttonOn"	, !buttonOn);
            edit.setProperty( "/EditOn" 	, !editOn);
            if( !editOn ){
                edit.setProperty( "/selectMode" 	, "Single");
                oTreeTable.expandToLevel(1);
                msgArea.removeAllItems();	
            }else{
                edit.setProperty( "/selectMode" 	, "None");
                oTreeTable.collapseAll();                         
            }
            // this.RemoveButtoncheck();
        },
        
        /**
         * Opens a dialog letting the user either confirm or cancel the quit and discard of changes.
         * @private
         */
        _showConfirmQuitChanges: function( event ) {
            var oComponent	=	this.getOwnerComponent(),
                oModel		=	this.getModel(),
                that		=	this,
                dialog		=	new sap.m.Dialog({
                    title: that._oResourceBundle.getText("ALERTE"),
                    type: 'Message',
                    content: new sap.m.Text({ text: that._oResourceBundle.getText("WARNING_MESSAGE") }),
        
                        beginButton: new sap.m.Button({
                                icon : "sap-icon://accept",
                                type: "Accept",
                                press: function () {
                                    // Update the message to server model
                                    that._oODataModel.deleteCreatedEntry();
                                    that.router.navTo("Overview", {}, true);
                                    that.onEdit();
                                    dialog.close();
                                }
                            }),
                            endButton: new sap.m.Button({
                                icon : "sap-icon://decline",
                                type: "Reject",
                                press: function () {
                                    dialog.close();
                                }
                            }),
                            afterClose: function () {
                                
                                dialog.destroy();
                                that.getView().setBusy( false );
                            }
                        });
            dialog.open();
        },
        onCancel: function( event ){
             var prestationModel	=	this.getModel( "postTable" ).getData(),
                pflag			=	this.checkODataChange( prestationModel, "Cancel" );
            // check if the model has been changed
            if (this.getModel().hasPendingChanges() || pflag ) {
                // get user confirmation first
                this._showConfirmQuitChanges( event ); 
            } else {
                // cancel without confirmation
                this.onEdit();
                this.getAllModels(this._ObjectId, this.getModel());
                if( event === "NavBack" ){
                    this.onNavBack();
                }
                this.getAllModels( this._ObjectId, this.getModel() );
            }
            
        },
        
        onLitigePopulate: function( event ){
            var value	= event.getParameter( "value" ),
                button	= event.getSource().getParent().getButtons()[0];
                
            // Set Enable if TextArea populate
            button.setEnabled( value.length > 0 );
        },
        
        Litige: function( event ){ 
            var source	=	event.getSource(),
                context	=	source.getParent().getBindingContext( "postTable" ),
                path	=	context.getPath(),
                model	=	context.getModel(),
                litige	=	source.getProperty( "color" ),
                edit	=	this.getView().getModel( "Edit" ),
                line	=	model.getProperty( path );	
            if( line.RECPT ){	
                if( !this._Litige ){
                    this._Litige = sap.ui.xmlfragment( "iae.fragment.LitigePopUp", this);
                    this.getView().addDependent(this._Litige);
                }
                if( litige	===	"Red"	){
                    this._Litige.setTitle( this._oResourceBundle.getText( "RECEPT_LITIGE" ) );
                    edit.setProperty( "/Litige", true );
                }else{
                    this._Litige.setTitle( this._oResourceBundle.getText( "RECEPT" ) );
                    edit.setProperty( "/Litige", false );
                }
                // this._Synthese.setModel( line );
                this._Litige.path	=	path;
                this.getView().getModel( "Edit" ).setProperty( "/LTGTX", "" );
                 this._Litige.open();
            }
        },
        
        LitigeClose: function(){
            this.getView().getModel( "Edit" ).setProperty( "/LTGTX", "" );
            this._Litige.close();
        },
        UploadFile: function ( event ){
            var imgModel		=	this.getView().getModel( "UploadImage" ),
                modelLine		=	this.getView().getModel( "postTable" ).getProperty( this._oFilePopover.path ),
                fileUploader	=	this._oPopover.getContent()[0].getItems()[1].getItems()[0],
                objid			=	this._ObjectId,
                objtp			=	"",
                fname			=	imgModel.getProperty( "/URL" ),
                anfps			=	modelLine.ANFPS,
                ebeln			=	"",
                descr			=	imgModel.getProperty( "/description" );
                ebeln	=	modelLine.EBELN;
                if( modelLine.HEADR !== "X" ){
                    objtp	=	"D";
                }
                else{
                    objtp	=	"I";
                }
                this.uploadPress( fileUploader, objid, objtp, fname, anfps, ebeln, descr );
                this.closePopOver();
        },
        /**
         * On Type not allowed
         * @param  {jQuery.Event} oEvent 
         */
        uploadPress: function( oFileUploader,  objid, objtp, fname, anfps, ebeln , descr ) {
            var oDataModel 		= this.getModel();
            
            if( !oFileUploader.getValue() ) {
                //	Error Choose an image first
                sap.m.MessageToast.show(
                    this._oResourceBundle.getText( "UPLOAD_CHOOSE_FILE" )
                );
                return;
            }
    
            // Refresh Token
            oDataModel.refreshSecurityToken( null, {
                async: false
            });
    
            //	Remove previous Header Parameters
            oFileUploader.removeAllHeaderParameters();
    
            //	Set File Name
            oFileUploader.insertHeaderParameter(
                new sap.ui.unified.FileUploaderParameter({
                    name: 	"slug", 
                    value: 	objid + "~" + objtp + "~" + fname + "~" + descr + "~" + anfps + "~" + ebeln
                })
            );
    
            //	Set CSRF Token
            oFileUploader.insertHeaderParameter(
                new sap.ui.unified.FileUploaderParameter({
                    name: 	"X-CSRF-Token", 
                    value: 	oDataModel.getHeaders()['x-csrf-token']
                })
            );
    
            //	Freeze the View
            this.getView().setBusy( true );
    
            //	Upload Image
            oFileUploader.upload();
        },
        /**
         * On Upload Complete
         * @param  {jQuery.Event} oEvent 
         */
        uploaderUploadComplete: function( oEvent ) {
            var oView 		=	this.getView(),
                vStatus 	=	oEvent.getParameter( "status" ),
                vDevis		=	this._ObjectId,
                postModel	=	this.getView().getModel( "postTable" ),
                modelTab	=	this.getView().getModel( "FileTable" ),
                entitySet	=	"/FILESSet",
                that		=	this;
                
        
            //	Build Filter for Article Number
            
                var filter 		= new sap.ui.model.Filter({ 
                    path 	: 	"DAMNB",
                    operator: 	sap.ui.model.FilterOperator.EQ,  
                    value1 	: 	vDevis
                });
            
    
            if ( vStatus === 201 || vStatus === 200 ) {
                this.uploadFile = true;
                this._oODataModel.read( entitySet, {
                    filters: [ filter ],
                    success: function( oData ) {
                        //	Free the View
                        oView.setBusy( false );
    
                        //	Update Image Table Model
                        modelTab.setData( oData.results );
    
                        //	Success Message
                        sap.m.MessageToast.show( that._oResourceBundle.getText( "UPLOAD_SUCCESS" ) );
                    },
                    error: function( oError ) {
                        //	Free the View
                        oView.setBusy( false );
    
                    }
                });
                
                this._oODataModel.read( "/HEADRSet('" + this._ObjectId + "')/ITEMSSet()", {
                    success: function ( oData ) {
                        postModel	=	oData.results;
                        that.showValidButton( postModel );
                        that.treeModel( postModel );
                        that.getView().byId("ITable").collapseAll();
                    },
                    error: function( err ){
                        sap.m.MessageToast.show( "ERROR" );
                    }
                } );
            } else {
                //	Free the View
                oView.setBusy( false );
    
                //	Success Message
                sap.m.MessageToast.show( that._oResourceBundle.getText( "UPLOAD_FAILED" ) );
            }
        },
        /**
         * On Type not allowed
         * @param  {jQuery.Event} oEvent 
         */
        uploaderTypeMissmatch: function( oEvent ) {
            var aFileTypes 			= oEvent.getSource().getFileType(),
                sSupportedFileTypes = aFileTypes.join(", "),
                that				=	this;
            
            //	Check if file extention allowed
            jQuery.sap.each( aFileTypes, function(key, value) {
                aFileTypes[key] = "*." +  value;
            });
            
            //	Error Message
            sap.m.MessageToast.show(
                this._oResourceBundle.getText( "UPLOAD_TYPE_MISSMATCH" , [
                    oEvent.getParameter("fileType"), 
                    sSupportedFileTypes
                    ]
                )
            );
        },
        
        
        onFilePreview: function( event ){
            var oView			=	this.getView(),
                oHtml 			=	new sap.ui.core.HTML(),
                model			=	event.getSource().getParent().getParent().getBindingInfo( "items" ).model,
                path			=	event.getSource().getParent().getBindingContext( model ).getPath(),
                row				=	this.getView().getModel( model ).getProperty( path ),
                oBundle 		= 	this.getView().getModel("i18n").getResourceBundle(),
                sPdfURL			=	row.FISRC,
                sHtmlContent;
    
            if( row.MIME_TYPE.includes( "PDF" ) || row.MIME_TYPE.includes( "IMAGE" ) || row.MIME_TYPE.includes( "JPEG" ) ){
                // Create Dialog
                var oDialog 		= new sap.m.Dialog({
                    title: 		oBundle.getText( "FILES" ),
                    resizable: 	false,
                    beginButton: new sap.m.Button({
                        text: oBundle.getText( "CLOSE" ),
                        press: function() {
                            oDialog.close();
                        }
                    }),
                    afterClose: function() {
                        oDialog.destroy();
                    }
                });
        
            
                 //	Set HTML Content
                sHtmlContent		= "<iframe src=" + sPdfURL + " width='700' height='700'></iframe>";
                oHtml.setContent( sHtmlContent ); 
        
                //	Add HTML to Dialog
                oDialog.addContent( oHtml );
        
                //	Open Dialog
                oView.addDependent( oDialog );
                oDialog.open();
            }else{
                window.open(	sPdfURL , "Preview" , "" );
            }
            
            
        
        },
        // onOpenPdf: function( event ) {
        // 	var that	=	this,
        // 		oView	=	this.getView(),
        // 		oHtml 	=	new sap.ui.core.HTML(),
        // 		sPdfURL,
        // 		sHtmlContent;
        // 	sap.ui.localResources("Image");
        // 	sPdfURL	=	"Image/Devis_pdf2.pdf";


        // 	// Create Dialog
        // 	var oDialog 		= new sap.m.Dialog({
        // 		title: 		"ANFNR",
        // 		resizable: 	false,
        // 		beginButton: new sap.m.Button({
        // 			text: that._oResourceBundle.getText( "CLOSE" ),
        // 			press: function() {
        // 				oDialog.close();
        // 			}
        // 		}),
        // 		afterClose: function() {
        // 			oDialog.destroy();
        // 		}
        // 	});

        
     // 		//	Set HTML Content
        // 	sHtmlContent		= "<iframe src=" + sPdfURL + " width='700' height='700'></iframe>";
        // 	oHtml.setContent( sHtmlContent ); 

        // 	//	Add HTML to Dialog
        // 	oDialog.addContent( oHtml );
 
        // 	//	Open Dialog
        // 	oView.addDependent( oDialog );
        // 	oDialog.open();
            
        // },
        // viewFile: function( event ){
        // 	var source	=	event.getSource(),
        // 		path	=	source.getParent().getBindingContext( "FileTable" ).getPath(),
        // 		model 	=	this.getModel( "FileTable" ),
        // 		URL 	=	model.getProperty( path + "/FISRC" ),
        // 		oHtml 	=	new sap.ui.core.HTML(),
        // 		that	=	this,
        // 		sHtmlContent;
            
        // 	// Create Dialog
        // 	var oDialog 		= new sap.m.Dialog({
        // 		title: 		model.getProperty( path + "/DESCR" ),
        // 		resizable: 	false,
        // 		beginButton: new sap.m.Button({
        // 			text: that._oResourceBundle.getText( "CLOSE" ),
        // 			press: function() {
        // 				oDialog.close();
        // 			}
        // 		}),
        // 		afterClose: function() {
        // 			oDialog.destroy();
        // 		}
        // 	});

        
     // 		//	Set HTML Content
        // 	sHtmlContent		= "<iframe src=" + URL + " width='700' height='700'></iframe>";
        // 	oHtml.setContent( sHtmlContent ); 

        // 	//	Add HTML to Dialog
        // 	oDialog.addContent( oHtml );
 
        // 	//	Open Dialog
        // 	that.getView().addDependent( oDialog );
        // 	oDialog.open();
        // },
        
        bonValidation: function( event ){
            var source	=	event.getSource(),
                service	=	this.getModel(),
                that	=	this,
                fctPrm	=	{};
            this.getView().setBusy( true );
            
            fctPrm.DAMNB		= this._ObjectId;

            if( source.getProperty("type")	===	"Accept" ){
                fctPrm.OPERA	=	"OK";
            }else{
                fctPrm.OPERA	=	"KO";
            }
            
            var	param = {	method: "GET",
                            urlParameters: fctPrm,
                            success: function(data, response) {
                                sap.m.MessageToast.show( that._oResourceBundle.getText( "SUBM_SUCCESS") );
                                that.readModel( that._oODataModel );

                                // Model Refresh
                                service.refresh();
                                that.getView().setBusy( false );
                            },
                            error: function(error) {
                                //	Disable busy indicator
                                that.getView().setBusy(false);
                                
                                //	Display message
                                sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
                            }
                        };
            service.callFunction("/Bon_Valid", param);
            
        },
        
        managerValidation: function( event ){
            var source	=	event.getSource(),
                service	=	this.getModel(),
                // model	=	this.getModel().getProperty( "/HEADRSet('" + this._ObjectId +"')"),
                model	=	{},
                that	=	this;
            if( source.getProperty("type") === "Accept" ){
                // model.OPERA	=	"V";
                model.DAMNB	= this._ObjectId;
                model.OPERA	= "V";
            }else if( source.getProperty("type") === "Reject" ){
                // model.OPERA	=	"R";
                model.DAMNB	= this._ObjectId;
                model.OPERA	= "R";
            }else{
                // model.OPERA	=	"O";
                model.DAMNB	= this._ObjectId;
                model.OPERA	= "O";
            }
                                
            
            var	param = {	method: "GET",
                            urlParameters: model,
                            success: function(data, response) {
                                sap.m.MessageToast.show( "VALIDATION_DEMANDE" );
                                that.readModel( that._oODataModel );
                                
                                // Model Refresh
                                service.refresh();
                                that.getView().setBusy( false );
                            },
                            error: function(error) {
                                //	Disable busy indicator
                                that.getView().setBusy(false);
                                
                                //	Display message
                                sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
                            }
                        };
            if( model.OPERA	===	"R" ){
                var dialog		=	new sap.m.Dialog({
                    title: that._oResourceBundle.getText("CONFIRM"),
                    type: 'Message',
                    content: new sap.m.Text({ text: that._oResourceBundle.getText("CONFIRM_CANCEL") }),
        
                        beginButton: new sap.m.Button({
                                icon : "sap-icon://accept",
                                type: "Accept",
                                press: function () {
                                    
                                    that.getView().setBusy( true );
                                    service.callFunction("/Manager_Valid", param);
                                    dialog.close();
                                }
                            }),
                            endButton: new sap.m.Button({
                                icon : "sap-icon://decline",
                                type: "Reject",
                                press: function () {
                                    dialog.close();
                                }
                            }),
                            afterClose: function () {
                                dialog.destroy();
                            }
                        });
            dialog.open();	
            }else{
                this.getView().setBusy( true );
                service.callFunction("/Manager_Valid", param);
            }
        },
        
        RFQSend: function( event ){
            var source	=	event.getSource(),
                service	=	this._oODataModel,
                path	=	Number( source.getParent().getBindingContext( "FournisseurTable" ).getPath().split( "/" )[1] ),
                hPath	=	Number( this.matnrPath.split( "/items/" )[1] ),
                model	=	this.getModel("postTable").getProperty( "/items/" + hPath + "/items/" + path ),
                that	=	this;
            delete model["ACTVT"];
            delete model["__metadata"];
            this.getView().setBusy( true );
            
            var	param = {	method: "GET",
                            urlParameters: model,
                            success: function(data, response) {
                                sap.m.MessageToast.show( that._oResourceBundle.getText( "SUCCESS") );
                                that.getView().setBusy(false);
                            },
                            error: function(error) {
                                //	Disable busy indicator
                                that.getView().setBusy(false);
                                
                                //	Display message
                                sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
                            }
                        };

            service.callFunction("/RFQ_Send", param);
        },
        
        GoodReceipt: function( event ){
            var service	=	this.getModel(),
                path	=	this._Litige.path,
                model	=	this.getModel("postTable").getProperty( path ),
                edit	=	this.getView().getModel( "Edit" ),
                that	=	this;
            this.getView().setBusy( true );
            model.LTGTX = edit.getProperty( "/LTGTX");
            delete model["__metadata"];
            delete model["checkEditable"];
            delete model["editable"];
            delete model["items"];
            delete model["ACTVT"];
            if( edit.getProperty( "/Litige") ){
                model.GR_OK	=	false;
                model.GR_KO	=	true;
            }else{
                model.GR_KO	=	false;
                model.GR_OK	=	true;
            }
            
            var	param = {	method: "GET",
                            urlParameters: model,
                            success: function(data, response) {
                                sap.m.MessageToast.show( that._oResourceBundle.getText( "RECEIPT_SUCCESS") );
                                that.readModel( that._oODataModel );
                                that._Litige.close();
                                // Model Refresh
                                service.refresh();
                                that.getView().setBusy(false);
                            },
                            error: function(error) {
                                //	Disable busy indicator
                                that.getView().setBusy(false);
                                
                                //	Display message
                                sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
                            }
                        };

            service.callFunction("/Goods_Receipt", param);
        },
        
        prestationSearch: function( event ){
            var value	=	event.getParameter("value"),
                filters	=	[];

            filters.push( new sap.ui.model.Filter( "NAME1" , sap.ui.model.FilterOperator.Contains , value ));
            filters.push( new sap.ui.model.Filter( "WERKS" , sap.ui.model.FilterOperator.Contains , this.byId( "selectStore" ).getSelectedKey()  ) );
            this._NewPoste.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
        },
        
        checkQuantity: function( event ){
            var source	=	event.getSource(),
                value	=	source.getValue();
            if( Number( value ) <= 0 ){
                source.setValue( "1" );
            }
        },
        
        confirmPrestation: function( event ){
            var path        =   event.getParameter("selectedContexts")[0].getPath(),
                currentView	=	this.getView(),
                service		=	this.getModel(),
                postModel	=	currentView.getModel( "postTable" ).getData(),
                data        =   service.getProperty( path ),
                line        =   {},
                exist		=	false;
            jQuery.each( postModel.items,function( index, row ){
                if( row.MATNR === data.MATNR && row.ACTVT !== "D"){
                    exist	=	true;
                }
            });
            if( !exist ){
                line.DAMNB			=	this._ObjectId;
                line.HEADR			=	"X";
                line.MATNR			=	data.MATNR;
                line.MAKTX			=	data.NAME1;
                // line.LIFNR			=	data.IDNLF;
                line.MENGE			=	"1.00";
                line.NETPR			=	"0.00";
                line.GR_OK			=	false;
                line.GR_KO			=	false;
                line.ACTVT			=	"N";
                if( !postModel.items ){
                    line.ANFPS		=	"90001";
                    postModel.items = [];
                }else if( postModel.items.length - 1 < 0 ){
                    line.ANFPS		=	"90001";
                }else{
                    var anfps			=	( Number( postModel.items[ postModel.items.length - 1 ]["ANFPS"] ) + 1 ) + "" ;
                    if( anfps.startsWith("9") ){
                        line.ANFPS			=	anfps.substr(1);
                    }else{
                        line.ANFPS			=	anfps;
                    }
                    while( line.ANFPS.length < 4 ){
                        line.ANFPS			=	"0" + line.ANFPS;
                    }
                    line.ANFPS				=	"9" + line.ANFPS;
                }
                postModel.items.push(line);
                currentView.getModel( "postTable" ).setData( postModel );
            }
            var filters	=	[];
            filters.push( new sap.ui.model.Filter( "NAME1" , sap.ui.model.FilterOperator.Contains , "" ) );
            filters.push( new sap.ui.model.Filter( "WERKS" , sap.ui.model.FilterOperator.Contains , this.byId( "selectStore" ).getSelectedKey()  ) );
            this._NewPoste.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
            
        },
        handleClose:function(){
            var filters	=	[];
            filters.push( new sap.ui.model.Filter( "NAME1" , sap.ui.model.FilterOperator.Contains , "" ) );
            filters.push( new sap.ui.model.Filter( "WERKS" , sap.ui.model.FilterOperator.Contains , this.byId( "selectStore" ).getSelectedKey()  ) );
            this._NewPoste.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
        },
        onDelete: function(event){
            var source	=	event.getSource(),
            service	=	this.getModel(),
            that	=	this,
            fctPrm	=	{};
            this.getView().setBusy( true );
            
            fctPrm.DAMNB		= this._ObjectId;

            var	param = {	method: "GET",
                            urlParameters: fctPrm,
                            success: function(data, response) {
                                sap.m.MessageToast.show( that._oResourceBundle.getText( "SUCCESS") );
                                that.readModel( that._oODataModel );

                                // Model Refresh
                                service.refresh();
                                that.getView().setBusy( false );
                                that.onNavBack();
                            },
                            error: function(error) {
                                //	Disable busy indicator
                                that.getView().setBusy(false);
                                
                                //	Display message
                                sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
                            }
                        };
            service.callFunction("/Supprimer_demande", param);
            
        },
        checkMandatoryField: function(){
            var mandatoryFields = [	"enTeteTxt" , "dateFinTravauxDtpck" , "prenomTxt" , "nomTxt" , "ageTxt" ],
                that			= this,
                valid			= true;
            mandatoryFields.forEach(function(id){
                var el	= that.byId(id);
                if(el.getValue().length > 0){
                    el.setValueState( "None");
                }else{
                    el.setValueState( "Error");
                    valid		= false;
                }
            });
            return valid;
            
        }
        
        
    });

}
);