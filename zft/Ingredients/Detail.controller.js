jQuery.sap.require( "sap/ui/model/Filter" );
jQuery.sap.require( "sap/ui/model/FilterOperator" );
jQuery.sap.require( "jquery.sap.resources" );
jQuery.sap.require( "sap/ui/Device" );
jQuery.sap.require( "sap/m/MessageBox" );
jQuery.sap.require( "sap/m/SplitContainer" );
jQuery.sap.declare(	"com.ODataFileUploader.Component");
jQuery.sap.require("sap.ui.unified.FileUploader");
jQuery.sap.require( "sap/m/MessageToast" );
jQuery.sap.require( "sap/m/StandardListItem" );
jQuery.sap.require(	"CatalogMat/util/Formatter" );


sap.ui.controller( "CatalogMat.Controller.Detail" , {
	/**
	* Called when a controller is instantiated and its View controls (if available) are already created.
	* Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
	* @memberOf test.detail
	*/
	
	Formatter : CatalogMat.util.Formatter,
	thisDetail:	null,
	onInit: function() {
		this.getView().addStyleClass( "sapUiSizeCompact" );
		
		var thisDetail = this;
		this.InitModels();
		
		//	Routing
		this.router 	= sap.ui.core.UIComponent.getRouterFor(this);
		this.router.attachRoutePatternMatched( this.handleRouting , this);
		
		this._BusyDialog = sap.ui.xmlfragment(
			"CatalogMat.Fragment.BusyDialog",
			this
		);
		this.getView().addDependent(this._BusyDialog);
		
		/**
		 * if the article is block for edit unlock the article without
		 * on close window/tab or refresh tab
		 */
		window.onbeforeunload = function (event) {
		    var oBundle 	= 	thisDetail.getView().getModel("i18n").getResourceBundle(),
			    message 	=	oBundle.getText( "WARNING_MESSAGE" );
		    if( thisDetail.getView().getModel( "Edit" ).getProperty( "/EditOn" ) ){
			    if (typeof event === 'undefined') {
			        event = window.event;
			    }
			    if (event) {
			    	thisDetail.onLockEdit("U", thisDetail._artNumber, true);
			        event.returnValue = message;
			    }
			    return message;
			}
		}
		sap.ui.getCore().getMessageManager().registerObject(this.getView(), true);
		var oMessagesModel = sap.ui.getCore().getMessageManager().getMessageModel();
		this._oBinding = new sap.ui.model.Binding(oMessagesModel, "/", oMessagesModel.getContext("/"));
		
		
	},
	InitModels: function(){
		
		var oModel = new sap.ui.model.resource.ResourceModel( { bundleUrl:"./i18n/i18n.properties" } );
      	sap.ui.getCore().setModel(oModel, "i18n");
		
		// Article Data model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "articleData" );

		// file model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "articleFileTable" );

		// sourcing model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "SourcingData" );
		
		// sourcing status model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "SourcingStatus" );

		// sourcing file model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "sourcingFile" );
		
		// sourcing file table model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "sourcingFileTable" );

		// recette table model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "recipeTable" );
		
		// recipe table filter model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "recipeFilter" );

		// Volume model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "volumeTable" );
		
		// volume table filter model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "volumeFilter" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "journalTable" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "NewProductStats" );
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "NewProduct" );
		
		// upload file model
		this.getView().setModel( new sap.ui.model.json.JSONModel( { "descriptionSate"	:	"None",
																	"urlState"			:	"None"		} ), "UploadImage" );

		// Image table model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "imageTable" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel( { "Text"			:	"text",
																	"Select"		:	"select"		} ), "helpModel" );

		
		this.getView().setModel( new sap.ui.model.json.JSONModel( {	
																		"totalP"	:	0,
																		"totalM"	:	0 }), "total" );
		// Model for edition article
		// this.getView().setModel( new sap.ui.model.json.JSONModel({	"EditOn" 	:	false,
		// 															"delete" 	: 	"None",
		// 															"buttonOn" 	: 	true ,
		// 															"FileEdit"	:	false,
		// 															"Status"	:	"",
		// 															"FileDelete" 	: 	"None"	}), "Edit" );
		


	},
	handleRouting: function( event ){
		this.pageName 	=	event.getParameter( "name" );
		var pageName 	=	this.pageName;
		this.byId( "iconTabDetail" ).setSelectedKey( "infoGeneralTab" );

		if( pageName === "Overview" ) {
			if( this.getView().getModel( "Edit" ).getProperty( "/EditOn" ) || this.getView().getModel( "Edit" ).getProperty( "/FileEdit" ) ){
				this.onEdit();
			}

			var msgArea 				= this.getView().byId( "msgArea" );
			msgArea.removeAllItems();
			return;
		}
		else if( pageName === "NewArticle"){
			this.onEdit();
		}
		else {
			var article			= event.getParameter( "arguments" ).Article;
			this.readModel( article );
		}

	},
	
	/**
	 *	This function check if this article is block for edit by the server
	 * 	Call by onEdit function and call the Lock_Unlock_Article server function
	 */
	onLockEdit: function ( actionCode , articleNumber , OEdit, edit){
		var that			=	this;
		if( !window.origin.includes( "webide" ) && this._artNumber !== "$" && this.pageName === "Detail" ){
			that._BusyDialog.open();
			
			jQuery.ajax({
	    		url: 			"/sap/bc/ZMOB_LOCK_SRV?action=" + actionCode + "&object=CATMAT&objectKey=" + articleNumber,  
			    type: 			"POST",
	            contentType: 	"application/json",
	
	
			    success: function (result) { 
			     that._BusyDialog.close();
				if( !result ){
					return;
				}
				// Success if the article isn't open for edit by another user
				// Lock or unlock the article for edit
				if( result.Type === "S" ) {
					if( !OEdit ){
						edit.setProperty( "/delete" 		, "Delete" );
						edit.setProperty( "/FileDelete" 	, "Delete" );
					}else{
						edit.setProperty( "/delete" 		, "None" );
						edit.setProperty( "/FileDelete" 	, "None" );
					}
				}	
				// Error if the article is lock for edit by another user
				// can't lock or unlock this article for edit 
				else{	
					sap.m.MessageToast.show( result.MessageText );
					// that.getView().getModel( "Edit" ).setProperty( "/EditOn" , !OEdit );
					// that.getView().getModel( "Edit" ).setProperty( "/FileEdit" , !OEdit );
					// that.getView().getModel( "Edit" ).setProperty( "/buttonOn" , OEdit );
					that.onEdit( "lock" );
					// reset the UI edit mode
					return;
					
				}
			    },  
			    error: function (e) {  
			    	if( e.status === 400 ){
		    			that.onLockEdit( actionCode , articleNumber , OEdit , edit);
		    		}else{
			    		// Disable busy indicator
						that._BusyDialog.close();				
						that.onEdit( "lock" );
						//	Display message
						sap.m.MessageToast.show( e.statusText );
		    		}
				}
			});  
		}
		
	},
	
	readModel: function ( articlePath ) {
		var service 	=	this.getView().getModel( "CatMatService" ),
			thisDetail	= this,
			msgArea 	= this.getView().byId( "msgArea" );
		thisDetail._BusyDialog.open();

		service.read( "/ArticleSet" + articlePath , {
			urlParameters: 	"$expand=AR2FL,AR2RC,AR2SR,AR2VL,AR2IM,AR2SF,AR2DM,AR2SS,AR2HS",
			success: function ( oData ) {	
				thisDetail._artNumber	=	oData.MATNR;
				thisDetail.getView().getModel( "articleData" ).setData( oData );
				
				// if( oData.RFMAT !== "" ){
				// 	// thisDetail.getView().getModel( "Edit" ).setProperty( "/Status", "90" );
				// 	thisDetail.setStatusFilter();
				// }

				thisDetail.getView().getModel( "volumeTable" ).setData( oData.AR2VL.results );
				var date	=	new Date(),
					day		=	date.getUTCDate() + "",
					month	=	date.getMonth() + 1 + "";
				if( day.length === 1 ){
					day	=	"0" + day;
				}
				if( month.length === 1 ){
					month	=	"0" + month;
				}
				thisDetail.getView().getModel( "volumeFilter" ).setProperty( "/APDEB", day + "." + month + "." + date.getUTCFullYear() + " - 31.12.2999" );
				thisDetail.VolumeSearch();

				thisDetail.getView().getModel( "articleFileTable" ).setData( oData.AR2FL.results );

				thisDetail.getView().getModel( "imageTable" ).setData( oData.AR2IM.results );

				thisDetail.getView().getModel( "recipeTable" ).setData( oData.AR2RC.results );
				thisDetail.getView().getModel( "recipeFilter" ).setProperty( "/APDEB", day + "." + month + "." + date.getUTCFullYear() + " - 31.12.2999" );
				thisDetail.recipeSearch();
				thisDetail.getView().getModel( "SourcingStatus" ).setData( oData.AR2SS.results );

				thisDetail.getView().getModel( "SourcingData" ).setData( thisDetail.addStatusToSourcing( oData.AR2SS.results , oData.AR2SR.results ) );
				
				thisDetail.getView().getModel( "sourcingFile" ).setData( oData.AR2SF.results );
				thisDetail.getView().getModel( "journalTable" ).setData( oData.AR2HS.results );
				
				var check	=	false,
					model	=	oData.AR2SR.results;
				
				for (var i = 0; i < model.length;  i++) {
					if( model[i].STATS !== "10" ){
						check	=	true;
						break;
					}
				}
				thisDetail.getView().getModel( "Edit" ).setProperty( "/Unit" , !check );

				thisDetail._BusyDialog.close();
				
				// thisDetail.readHistory( oData.MATNR, service );
			},
			error: function ( error ) {
			 	thisDetail._BusyDialog.close();
			 	var oMsgStrip = new sap.m.MessageStrip({
											text: 				JSON.parse(error.responseText).error.message.value,
											showCloseButton: 	true,
											showIcon: 			true,
											type: 				"Error"
										});
					//	Add Message to VBox
					msgArea.addItem( oMsgStrip );
			}
		});
	},
	
	// readHistory: function( matnr, service ){
	// 	var filter			=	[ new sap.ui.model.Filter( "PRNUM", sap.ui.model.FilterOperator.Contains, matnr ) ],
	// 		historyModel	=	this.getView().getModel( "journalTable" );
			
 //     	service.read( "/HistorySet",{   
 // 			filters: filter ,
	// 		success: function( oData ) {
 //       		historyModel.setData( oData.results );
 //           },
 //           error: function( error ) {
 //           }
	//     });	
	// },
	
	addStatusToSourcing: function( statmodel, model ){
		var status = statmodel.reduce(function(result, item) {
				if (!result[item.SOKEY]) {
					result[item.SOKEY] = [];
				}
				result[item.SOKEY].push(item);
				
				return result;
			}, {});
		for( var i = 0 ; i < model.length ; i++ ){
			//
			if(model[i].MATNR.startsWith( "AF" )){
				var checkIfhasStatusInAllowedList = function(stat){ 
					return (stat.STATS === model[i].STATS);
					};
				var checkResutlt =  status[ model[i].SOKEY ].filter(checkIfhasStatusInAllowedList).length;
				if(checkResutlt === 0){
					status[ model[i].SOKEY ].push({	STATS: model[i].STATS ,
													MATNR: model[i].MATNR,
													MFRNR: model[i].MFRNR,
													SOKEY: model[i].SOKEY,
													VTEXT: model[i].TSTAT });
				}	
			}
			
			//
			model[i].statut	=	status[ model[i].SOKEY ];
			if(!isNaN(model[i].VLCRN)){
				model[i].VLCRN  =	parseInt(model[i].VLCRN, 10).toString();
			}
		}
		this.statusTable	=	status[ "000" ];
		return model;
	},
	
	// setStatusFilter: function(){
	// 	var select	=	this.byId( "selectStatus" ).getBinding( "items" ),
	// 		filter 		= [new sap.ui.model.Filter({	path 	: 	"STATS",
	// 													operator: 	sap.ui.model.FilterOperator.NE,  
	// 													value1 	: 	"90"
	// 												})];
	// 	select.filter( filter );
	// },
	
	/**
	 * Open the dialog of Article copy list 
	 */
	onBuyerList: function(event) {

		// create value help dialog
		if (!this._BuyerListDialog) {
			this._BuyerListDialog = sap.ui.xmlfragment(
				"CatalogMat.Fragment.BuyerList",
				this
			);
			this.getView().addDependent(this._BuyerListDialog);
			this.getView().setModel(new sap.ui.model.json.JSONModel(), "VHAcheteursSet");
			var service = this.getView().getModel("CatMatService"),
				thisDetail	=	this;
			service.read("/VHAcheteursSet", {
				success: function(oData) {
					thisDetail.getView().getModel("VHAcheteursSet").setData(oData.results);
				},
				error: function(error) {
	
				}
			});
		}
		var source	=	event.getSource().getId();
		this._BuyerListDialog.open();
		if( source.includes( "newProduct" ) ){
			this._BuyerListDialog.Type	=	"newBuyer";	
		}else{
			this._BuyerListDialog.Type	=	"existeBuyer";	
		}
	},

	confirmBuyer: function(event) {
		var items = event.getParameter("selectedItems"),
			tempDscr	=	[],
			tempFrn		=	[],
			str			=	"",
			newProduct	= this.getView().getModel("NewProduct").getData();
		
		items.forEach(function( item ){
			tempDscr.push( item.getDescription() + " " + item.getTitle());
			tempFrn.push( item.getInfo());
			str +=	item.getDescription() + " " + item.getTitle() + ", ";
		});
		
		newProduct.ACNUM_DESCR		=	tempDscr;
		newProduct.ACNUM			=	tempFrn;
		
		this._initDialog.getContent()[0].getAggregation( "form" ).getAggregation( "formContainers" )[0].getAggregation( "formElements" )[3].getFields()[0].setValueState( "None" );
		this._initDialog.getContent()[0].getAggregation( "form" ).getAggregation( "formContainers" )[0].getAggregation( "formElements" )[3].getFields()[0].setValue( str.substring(0, str.length - 2) );
		// var value	=	event.getParameter("selectedItem"),
		// 	data;
		// if( this._BuyerListDialog.Type === "newBuyer" ){
		// 	data = this.getView().getModel( "NewProduct" );
		// 	data.setProperty("/ACNUM_DESCR", value.getDescription() + " " + value.getTitle() );
		// 	data.setProperty("/ACNUM", value.getInfo());
		// 	this._initDialog.getContent()[0].getAggregation( "form" ).getAggregation( "formContainers" )[0].getAggregation( "formElements" )[3].getFields()[0].setValueState( "None" );
		// }else{
		// 	data = this.getView().getModel( "articleData" );
		// 	data.setProperty("/ACNUM", value.getInfo());
		// 	data.setProperty("/FNAME", value.getTitle());
		// 	data.setProperty("/LNAME", value.getDescription());
		// }
	},
	closeBuyerList: function( oEvent ){
		var binding 	=	oEvent.getSource().getBinding("items");
		binding.filter(new sap.ui.model.Filter("ACNUM", sap.ui.model.FilterOperator.Contains, ""));	
	},
	
	navigationTo: function(Page, Parameter, Bool) {
		var router = sap.ui.core.UIComponent.getRouterFor(this.getView());
		router.navTo(Page, Parameter, Bool);
	},
	
	onEdit: function ( source ) {
		var OEdit 			=	null,
			fictif			=	this.getView().getModel( "articleData" ).getProperty( "/FICTF" ),
			edit			=	this.getView().getModel( "Edit" );
		if( fictif ){	
			OEdit			=	edit.getProperty( "/EditOn" );
			edit.setProperty( "/buttonOn" 	, OEdit );
			edit.setProperty( "/EditOn" 		, !OEdit );
			edit.setProperty( "/FileEdit" 		, !OEdit );
			if( source !== "lock" ){
				if( !OEdit ){
					this.onLockEdit("L", this._artNumber, OEdit ,edit);
					edit.setProperty( "/FileDelete" 	, "Delete" );
				}else{
					this.onLockEdit("U", this._artNumber, OEdit ,edit);
					edit.setProperty( "/FileDelete" 	, "None" );
				}
			}
		}else{
			OEdit			=	edit.getProperty( "/FileEdit" );
			edit.setProperty( "/buttonOn" 	, OEdit );
			edit.setProperty( "/FileEdit" 		, !OEdit );
			if( !OEdit ){
				edit.setProperty( "/FileDelete" 	, "Delete" );
			}else{
				edit.setProperty( "/FileDelete" 	, "None" );
			}
		}
	},
	// changeItem: function( event ){
	// 	var items	=	event.getParameter( "selectedItem" ),
	// 		value	=	items.getText();	
	// },
	handleNavButtonPress: function(){
		if( this.getView().getModel( "Edit" ).getProperty( "/EditOn" ) ){
				var thisDetail		=	this,
				currentView		=	thisDetail.getView(),
				oBundle 		= 	currentView.getModel("i18n").getResourceBundle(),
				dialog			=	new sap.m.Dialog({
					title: oBundle.getText( "CONFIRM" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "WARNING_MESSAGE" ) }),
		
						beginButton: new sap.m.Button({
								icon : "sap-icon://accept",
								type: "Accept",
								press: function () {
									// Update the message to server model
									// thisDetail.navigationTo("Overview", "", false);
									window.history.go( -1 );
									thisDetail.onEdit();
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
								thisDetail._BusyDialog.close();
							}
				});
				dialog.open();
		}else{
			window.history.go( -1 );
		}
	},
	handleLoadItems: function(oControlEvent) {
		oControlEvent.getSource().getBinding("items").resume();
	},
	addSourcing: function( event ){
		var modelTable 		=   this.getView().getModel( "SourcingData" ).getData(),
            service 		=   this.getView().getModel( "CatMatService" ),
			line	    	=   service.createEntry("/SourcingSet").getObject();
		line.MATNR			=	this._artNumber;
		line.STATS			=	"10" ;
		line.TSTAT			=	"En cours";
		line.MEINS			=	this.getView().getModel( "articleData" ).getProperty( "/MEINS" );
		line.statut			=	this.statusTable;
		if(this._artNumber.startsWith( "AF" )){
			line.KBETR = this.getView().getModel("articleData").getProperty("/TARAP");
		}
		modelTable.push( line );
		this.getView().getModel( "SourcingData" ).setData( modelTable );
	},
	
	integerFormat: function( event ){
		var value	= event.getSource().getValue();
		event.getSource().setValue( value.replace( ".","" ) );
	},
	/**
	 * Initialistion of newproduct popUp
	 */
	NewFournisseurPress: function( event ){
		var source		=	event.getSource(),
			value		=	source.getValue(),
			context		=	source.getBindingContext( "SourcingData" );
		if( !this._newFournisseur ){
			this._newFournisseur = sap.ui.xmlfragment( "CatalogMat.Fragment.FournisseurList", this);
			this.getView().addDependent(this._newFournisseur);
		}
	// this.getView().setModel( new sap.ui.model.json.JSONModel(), "VHRecettesDetailsSet" );
	// var service	=	this.getView().getModel( "CarteService" );
	//    	service.read( "/VHRecettesDetailsSet",
	//          {    success: function( oData ) {
	//                  this.thisDetail.getView().getModel( "VHRecettesDetailsSet" ).setData( oData.results );
	//                  },
	//              error: function( error ) {
	                   
	//                  }
	//              });
		if( context ){
			this._newFournisseur.path =	context.getPath();
		}else{
			this._newFournisseur.path =	false;
		}
	 	
	 	this._newFournisseur.open();
	 	this._newFournisseur.getAggregation("_dialog").getAggregation("subHeader").getAggregation( "contentMiddle" )[0].setValue( value );
	 	this.handleDialogSearch( value , "MFRNR", this._newFournisseur.getBinding("items"));
	},
	
	AddFournisseur: function( event ){
		var path        =   event.getParameter("selectedContexts")[0].getPath(),
            // modelTable  =   this.getView().getModel( "SourcingData" ).getData(),
            service     =   this.getView().getModel( "CatMatService" ),
            data        =   service.getObject(path);
            // flag		=	false,
            // line        =   service.createEntry("/SourcingSet").getObject();
        // if( !this._newFournisseur.path ){
	       // for (var i = 0; i < modelTable.length; i++) {
	       // 	if( modelTable[i].MFRNR === data.MFRNR ){
	       // 		flag = true;
	       // 	}
	       // }
	       // if( !flag ){
		      // delete line["_bCreate"];
		      // line.MATNR	=	this.getView().getModel( "articleData" ).getData().MATNR;	
		      // line.MFRNR   =	data.MFRNR;
		      // line.MFRNM   =	data.MFRNM;
		      //  modelTable.push( line );
		      //  this.getView().getModel( "SourcingData" ).setData( modelTable );
	       // }
        // }else{
        	this.getView().getModel( "SourcingData" ).setProperty( this._newFournisseur.path + "/MFRNM", data.MFRNM);
        	this.getView().getModel( "SourcingData" ).setProperty( this._newFournisseur.path + "/MFRNR", data.MFRNR);
        // }
	},
	
	fournisseurChange:function( event ){
		var source	=	event.getSource(),
			path	=	source.getParent().getBindingContext( "SourcingData" ).getPath(),
			model	=	this.getView().getModel( "SourcingData" );
		model.setProperty( path + "/MFRNR", "" );
	}, 
	
	onSourcingDelete: function( event ){
		var modelTable	=	this.getView().getModel( "SourcingData" ).getData(),
			temp		=	[],
			path		=	event.getParameter("listItem").getBindingContext( "SourcingData" ).getPath().split("/")[1];
		for (var i=0; i<modelTable.length; i++) {
			if( i !== Number( path ) ){
				temp.push( modelTable[i] );
			}
		}
		this.getView().getModel( "SourcingData" ).setData( temp );
	},
	closeFournisseurList: function( oEvent ){
		this.handleDialogSearch("", "MFRNR", oEvent.getSource().getBinding("items"));
		this._newFournisseur.close();	
	},
	
	HandleFilePress: function( event ){
		
		var path		=	event.getSource().getBindingContext("SourcingData").getPath().split("/")[1],
			stats		=	this.getView().getModel( "SourcingData" ).getData()[path].STATS,
			fournisseur	=	this.getView().getModel( "SourcingData" ).getData()[path].MFRNR,
			key			=	this.getView().getModel( "SourcingData" ).getData()[path].SOKEY,
			srcFile 	=	this.getView().getModel( "sourcingFile" ).getData(),
			matnr		=	this.getView().getModel( "articleData" ).getProperty( "/MATNR" ),
			oBundle 	= 	this.getView().getModel("i18n").getResourceBundle(),
			// autorisation=	this.getView().getModel( "Edit" ).getProperty( "/AR2SF" ),
			FileTable 	=	[];
			// if( autorisation.includes( "M" ) || ( this.pageName === "NewArticle" && autorisation.includes( "C" ) ) ){
		
		if( Number( stats ) < 30 && matnr.startsWith( "AF" ) ){
			var dialog	= new sap.m.Dialog({
						title: oBundle.getText( "EMPTY_FOURNISSEUR" ),
						type: 'Message',
						content: new sap.m.Text({ text: oBundle.getText( "EMPTY_FOURNISSEUR_FIELD" ) }),
			
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
			if( !this._FilesUploadSourcing ){
				this._FilesUploadSourcing = sap.ui.xmlfragment( "CatalogMat.Fragment.FileTabPopUp", this );
				this.getView().addDependent(this._FilesUploadSourcing);
			}
			this._FilesUploadSourcing.sokey	=	key;
			this._FilesUploadSourcing.mfrnr	=	fournisseur;
		 	this._FilesUploadSourcing.open();
		 	for (var i=0; i<srcFile.length; i++) {
		 		if( srcFile[i].MFRNR === fournisseur){
		 			FileTable.push( srcFile[i] );
		 		}
		 	}
		 	this.getView().getModel( "sourcingFileTable" ).setData( FileTable );
		}
		// }
	},
	onCloseFileSourcing: function( event ){
		this._FilesUploadSourcing.close();
	},
	
	addFilePopOver: function (oEvent) {

		// create popover
		if (! this._oPopover) {
			this._oPopover = sap.ui.xmlfragment("CatalogMat.Fragment.addFilePopOver", this);
			this.getView().addDependent(this._oPopover);
		}

		var oButton = oEvent.getSource();
		jQuery.sap.delayedCall(0, this, function () {
			this._oPopover.openBy(oButton);
		});
	},
	// uploaderValueChange: function( event ){
	// 	var  value = event.getSource().getValue();
	// 	this.getView().getModel( "UploadImage" ).setProperty( "/Description", value );
	// },
	closePopOver: function(){
		var imgModel	=	this.getView().getModel( "UploadImage" );
		imgModel.setProperty( "/URL", "" );
		imgModel.setProperty( "/description", "" );
		imgModel.setProperty( "/descriptionSate", "None" );
		imgModel.setProperty( "/urlState", "None" );
		this._oPopover.close();
	},
	
	popOverText: function (oEvent) {

		// create popover
		if (! this._SourcingTextPopover) {
			this._SourcingTextPopover = sap.ui.xmlfragment("CatalogMat.Fragment.SourcingTextPopOver", this);
			this.getView().addDependent(this._SourcingTextPopover);
		}

		var oButton =	oEvent.getSource(),
			id		=	oButton.getId(),
			path	=	id.substr( id.length - 1 ),
			value	=	oButton.getBindingInfo("type").binding.getValue();
		jQuery.sap.delayedCall(0, this, function () {
			this._SourcingTextPopover.openBy(oButton);
		});
		this._SourcingTextPopover.getAggregation("content")[0].setValue( value );
		this._SourcingTextPopover.getAggregation("content")[0].setName( path );
	},
	sourcingTexteChange: function( event ){
		var model	=	this.getView().getModel( "SourcingData" ).getData(),
			source	=	event.getSource(),
			value	=	source.getValue(),
			path	=	source.getName();
		model[ Number( path ) ].STEXT	=	value;
		this.getView().getModel( "SourcingData" ).setData( model );
	},
	closeSourcingPopOver: function(){
		this._SourcingTextPopover.close();
	},
	
	GeneralInfoAddFilePopOver: function (oEvent) {

		// create popover
		if (! this._gInfoPopover) {
			this._gInfoPopover = sap.ui.xmlfragment("CatalogMat.Fragment.GeneralInfoaddFilePopOver", this);
			this.getView().addDependent(this._gInfoPopover);
		}

		var oButton = oEvent.getSource();
		jQuery.sap.delayedCall(0, this, function () {
			this._gInfoPopover.openBy(oButton);
		});
	},
	closegInfoPopover: function(){
		var imgModel	=	this.getView().getModel( "UploadImage" );
		imgModel.setProperty( "/URL", "" );
		imgModel.setProperty( "/description", "" );
		imgModel.setProperty( "/descriptionSate", "None" );
		imgModel.setProperty( "/urlState", "None" );
		this._gInfoPopover.close();
	},
	onImageDelete:function( event ){
		var path	=	Number( event.getParameter( "listItem" ).getBindingContextPath().split("/")[1] ),
			model	=	this.getView().getModel( "imageTable" );
		this.onLineDelete(model, path);
	},
	onSourcingFileDelete:function( event ){
		var path	=	Number( event.getParameter( "listItem" ).getBindingContextPath().split("/")[1] ),
			model	=	this.getView().getModel( "sourcingFileTable" ),
			srcModel=	this.getView().getModel( "sourcingFile" ),
			temp	=	[],
			flag	=	false,
			fikey	=	model.getProperty( "/" + path + "/FIKEY" );
		this.onLineDelete(model, path);
		for (var i=0; i<srcModel.getData().length; i++) {
			if( srcModel.getProperty( "/" + i + "/FIKEY"  )	!== fikey ){
				temp.push( srcModel.getProperty( "/" + i ) );
			}
			// if( srcModel.getProperty( "/" + i + "/MFRNR"  ) === model.getProperty( "/0/MFRNR"  ) ){
			// 	for (var j=0; j<model.getData().length; j++) {
			// 		if( srcModel.getProperty( "/" + i + "/FIKEY"  ) === model.getProperty( "/" + j + "/FIKEY"  ) ){
			// 			flag	=	true;
			// 			break;
			// 		}
			// 	}
			// 	if( flag ){
			// 		temp.push( srcModel.getProperty( "/" + i ) );
			// 	}
			// }else{
			// 	temp.push( srcModel.getProperty( "/" + i ) );
			// }
			// flag = false;
		}
		srcModel.setData( temp );
	},
	onFileDelete:function( event ){
		var path	=	Number( event.getParameter( "listItem" ).getBindingContextPath().split("/")[1] ),
			model	=	this.getView().getModel( "articleFileTable" );
		this.onLineDelete(model, path);
	},
	onLineDelete:function( model, path ){
		var temp	=	[];
		
		for (var i = 0; i < model.getData().length; i++) {
			if( i !== path ){
				temp.push( model.getData()[i] );
			}
		}
		model.setData( temp );	
	},
	onMainImageSelect:function( event ){
		var selected	=	event.getParameter( "selected" );
		if( selected ){
			this.getView().getModel( "articleData" ).setProperty( "/IMSRC", event.getSource().getBindingContext( "imageTable" ).getObject().FISRC );
		}
	},
	handleImagePress:function ( event ){
		var source 	=	event.getSource(),
			URL 	=	source.getSrc(),
			path	=	source.getBindingInfo( "src" ).binding.getContext().getPath().split("/")[1],
			model	=	this.getView().getModel( "imageTable" ).getData();

		if( !this._previewImageDialog ){
			this._previewImageDialog = sap.ui.xmlfragment( "CatalogMat.Fragment.imageDetailDialog", this);
			this.getView().addDependent(this._previewImageDialog);
		}
	 	this._previewImageDialog.open();

	 	this._previewImageDialog.setTitle( model[path].DESCR );

		var image 		=	this._previewImageDialog.getAggregation("content")[0];
		image.setSrc( URL );
		image.setWidth( "400px" );

	},
	closeDialog:function(){
		this._previewImageDialog.close();
	},
	
	ImageAddFilePopOver: function (oEvent) {

		// create popover
		if (! this._ImagePopover) {
			this._ImagePopover = sap.ui.xmlfragment("CatalogMat.Fragment.ImageAddFilePopOver", this);
			this.getView().addDependent(this._ImagePopover);
		}

		var oButton = oEvent.getSource();
		jQuery.sap.delayedCall(0, this, function () {
			this._ImagePopover.openBy(oButton);
		});
	},
	closegImagePopover: function(){
		var imgModel	=	this.getView().getModel( "UploadImage" );
		imgModel.setProperty( "/URL", "" );
		imgModel.setProperty( "/description", "" );
		imgModel.setProperty( "/descriptionSate", "None" );
		imgModel.setProperty( "/urlState", "None" );
		this._ImagePopover.close();
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

		if( row.FTYPE === "PDF" || row.FTYPE === "IMG"  ){
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
			var file_path = sPdfURL;
			var a = document.createElement('A');
			a.href = file_path;
			a.download = file_path.substr(file_path.lastIndexOf('/') + 1);
			document.body.appendChild(a);
			a.click();
			document.body.removeChild(a);
		}
		
		
	
	},
	
	onCancel:function(){
		var model	=	this.getView().getModel( "articleData" ).getData();
		this.readModel( "(MATNR='" + model.MATNR + "',MFRNR='" + model.MFRNR + "')" );
		this.onEdit();
	},
	/**
	 * Send to the server the new data of the article
	 */
	onModifArtCompleted: function( event ) {
			var currentView				= this.getView(),
				artService 				= currentView.getModel( "CatMatService" ),
				artHeadr				= currentView.getModel( "articleData" ).getData(),
				artFile					= currentView.getModel( "articleFileTable" ).getData(),
				artVolume				= currentView.getModel( "volumeTable" ).getData(),
				artRecette				= currentView.getModel( "recipeTable" ).getData(),
				artSourcing				= currentView.getModel( "SourcingData" ).getData(),
				artSrcFile	 			= currentView.getModel( "sourcingFile" ).getData(),
				artImage		 		= currentView.getModel( "imageTable" ).getData(),
				artSourcingStatus		= currentView.getModel( "SourcingStatus" ).getData(),
				arthistory				= currentView.getModel( "journalTable" ).getData(),
				oBundle 				= 	currentView.getModel("i18n").getResourceBundle(),
				that					=	this,
				artToModif 				= {},
				flag					= false,
				success 				= false,
				error 					= false,
				oMsgStrip				= null,
				thisDetail				= this,
				msgArea 				= this.getView().byId( "msgArea" );
			msgArea.removeAllItems();
			// if( !thisDetail._artNumber.includes( "AF" ) ){
			// 	thisDetail.onEdit();
			// 	return;
			// }
			
			
			if( artHeadr.MEINS	===	""	|| !artHeadr.MEINS ){
				artHeadr.MEINS	=	"0";
			}
			if( artHeadr.TARAP	===	""	|| !artHeadr.TARAP ){
				artHeadr.TARAP	=	"0";
			}
			if( artHeadr.MHDRZ	===	""	|| !artHeadr.MHDRZ ){
				artHeadr.MHDRZ	=	"0";
			}
			if(artHeadr.MAKTX.length > 40){
				var designationDialog	= new sap.m.Dialog({
						title: oBundle.getText( "INVALID_MAKTX" ),
						type: 'Message',
						content: new sap.m.Text({ text: oBundle.getText( "MAKTX_TOO_LONG" ) }),
			
						endButton: new sap.m.Button({
							icon : "sap-icon://decline",
							type: "Reject",
							press: function () {
								designationDialog.close();
							}
						}),
						afterClose: function () {
							designationDialog.destroy();
						}
					});
					designationDialog.open();
					return;	
			}
			for (var i=0; i<artSourcing.length; i++) {
				if( artSourcing[i].NTGEW === ""	||	!artSourcing[i].NTGEW || artSourcing[i].NTGEW === "0" ){
					artSourcing[i].NTGEW	=	"0.000";
				}
				if( artSourcing[i].KBETR === ""	||	!artSourcing[i].KBETR || Number( artSourcing[i].KBETR ) <= 0 ){
					var tarifDialog	= new sap.m.Dialog({
						title: oBundle.getText( "INVALID_FIELD" ),
						type: 'Message',
						content: new sap.m.Text({ text: oBundle.getText( "KBETR_EMPTY" ) }),
			
						endButton: new sap.m.Button({
							icon : "sap-icon://decline",
							type: "Reject",
							press: function () {
								tarifDialog.close();
							}
						}),
						afterClose: function () {
							tarifDialog.destroy();
						}
					});
					tarifDialog.open();
					return;
				}
			}	
			for ( i=0; i<artFile.length && !flag ; i++) {
				if( artFile[i].DESCR === "" ){
					flag	=	true;
					break;
				}
			}
			for (i=0; i<artSrcFile.length && !flag ; i++) {
				if( artSrcFile[i].DESCR === "" ){
					flag	=	true;
					break;
				}
			}
			for (i=0; i<artImage.length && !flag ; i++) {
				if( artImage[i].DESCR === "" ){
					flag	=	true;
					break;
				}
			}
			if( flag ){
				var enseigneDialog	= new sap.m.Dialog({
					title: oBundle.getText( "FIELD_EMPTY" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "DESC_EMPTY" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							enseigneDialog.close();
						}
					}),
					afterClose: function () {
						enseigneDialog.destroy();
					}
				});
				enseigneDialog.open();
			return;
			}
	
			for( i = 0 ; i < artSourcing.length ; i++ ){
				delete artSourcing[i]["statut"];
			}
	
			//	Prepare object for server call
			artToModif 				= artHeadr; 
			artToModif.AR2FL		= artFile;
			artToModif.AR2VL		= artVolume;
			artToModif.AR2RC		= artRecette;
			artToModif.AR2SR		= artSourcing;
			artToModif.AR2SF		= artSrcFile;
			artToModif.AR2IM		= artImage;
			artToModif.AR2SS		= artSourcingStatus;
			artToModif.AR2HS		= arthistory;
			artToModif.AR2DM 		= [];
			
			
			// if( this.pageName == "NewArticleCopy"){
			// 	artToModif = thisDetail.onSaveCopy( artToModif );
			// }

			//	Delete metadata
			delete artToModif["__metadata"];
			delete artToModif["Description"];
			

			jQuery.each( artToModif , function( index , field ) {
				if( jQuery.isArray( field )) {
					jQuery.each( field , function( indexj , item ) {
						delete item["__metadata"];
					});
				}
			});

			this.dataChanged 	= true;

			//	Set busy indicator
			this._BusyDialog.open();

			//	Call server
			artService.create( "/ArticleSet" , artToModif , {
				success: function( data, response ) {
					//	Disable busy indicator
					that._BusyDialog.close();

					if( response ){
						//	Display message
						if( response.headers["sap-message"] ){
							var message 	=	JSON.parse(response.headers["sap-message"]);
							if(message.details !== undefined){
								message.details.some(function(itm){
									if(itm.code === "ZMM/140" ){
										oMsgStrip		= new sap.m.MessageStrip({
												text: 				itm.message,
												showCloseButton: 	true,
												showIcon: 			true,
												type: 				"Warning"
											});
						
										//	Add Message to VBox
										msgArea.addItem( oMsgStrip );
										return true;
									}
									
								});
							}
							sap.m.MessageToast.show( message.message , {duration: 3000});
						}
					// //	Create Message
					// var message 	=	JSON.parse(response.headers["sap-message"]);	
					// oMsgStrip		= new sap.m.MessageStrip({
					// 		text: 				message.message,
					// 		showCloseButton: 	true,
					// 		showIcon: 			true,
					// 		type: 				"Success"
					// 	});
	
					// //	Add Message to VBox
					// msgArea.addItem( oMsgStrip );
					
				}
				thisDetail.onEdit();
				thisDetail.readModel( "(MATNR='" + data.MATNR + "',MFRNR='" + data.MFRNR + "')" );
					
				},
				error: function( error ) {
					//	Disable busy indicator
					that._BusyDialog.close();
					
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
		},
	GeneralUploadFile: function ( event ){
		var model			=	this.getView().getModel( "articleData" ),
			imgModel		=	this.getView().getModel( "UploadImage" ),
			fileUploader	=	event.getSource().getParent().getParent().getParent().getContent()[0].getItems()[1].getItems()[0],
			objnr			=	model.getProperty( "/MATNR" ),
			objtp			=	"I",
			fname			=	imgModel.getProperty( "/URL" ),
			mfrnr			=	"",
			descr			=	imgModel.getProperty( "/description" );
		if( descr && descr !==	"" && fname && fname !==	"" ){
			if( fileUploader.getId() === "SourcingFilesUploader" ){
				if( this._artNumber.includes( "AF" ) ){
					mfrnr			=	this._FilesUploadSourcing.sokey;
				}else{
					mfrnr			=	this._FilesUploadSourcing.mfrnr;
				}
			}
			imgModel.setProperty( "/descriptionSate", "None" );
			this.uploadPress( fileUploader, objnr, objtp, fname, mfrnr, descr );
		}else{
			if( !descr || descr ===	"" ){
				imgModel.setProperty( "/descriptionSate", "Error" );
			}else{
				imgModel.setProperty( "/descriptionSate", "None" );
			}
			if( !fname || fname ===	"" ){
				imgModel.setProperty( "/urlState", "Error" );
			}else{
				imgModel.setProperty( "/urlState", "None" );
			}
			return;
		}
		// switch (id) {
		// 	case "uploadFileSourcing":
		// 		this.closePopOver();		
		// 		break;
		// 	case "generalInfoFile":
		// 		this.closegInfoPopover();		
		// 		break;
		// 	case "UploadImage":
		// 		this.closegImagePopover();		
		// 		break;
		// }
		
	},
	/**
	 * On Type not allowed
	 * @param  {jQuery.Event} oEvent 
	 */
	uploadPress: function( oFileUploader,  objnr, objtp, fname, mfrnr, descr ) {
		var oDataModel 		= this.getView().getModel( "FileUpload" ),
			oBundle 		= sap.ui.getCore().getModel( "i18n" ).getResourceBundle();
		
		if( !oFileUploader.getValue() ) {
			//	Error Choose an image first
			sap.m.MessageToast.show(
				oBundle.getText( "UPLOAD_CHOOSE_FILE" )
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
				value: 	encodeURIComponent( objnr + "~" + objtp + "~" + fname + "~" + mfrnr + "~" + descr )
			})
		);

		//	Set CSRF Token
		oFileUploader.insertHeaderParameter(
			new sap.ui.unified.FileUploaderParameter({
				name: 	"X-CSRF-Token", 
				value: 	oDataModel.getHeaders()['x-csrf-token']
			})
		);
		
		this._BusyDialog.open();

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
			oBundle 	=	this.getView().getModel( "i18n" ).getResourceBundle(),
			vArtNum		=	oView.getModel( "articleData" ).getProperty("/MATNR"),
			id			=	oEvent.getParameter( "id" ),
			raw			=	oEvent.getParameter("responseRaw"),
			modelTab	=	null,
			entitySet	=	null,
			thisDetail	=	this,
			xmlDoc		=	jQuery.parseXML( raw ),
			uploadMsg	=	null;
			
		switch ( id ) {
			case "generalInfoUploader":
				modelTab	=	this.getView().getModel( "articleFileTable" );
				entitySet	=	"/FilesSet";
				this.closegInfoPopover();
				break;
			case "ImageFilesUploader":
				modelTab	=	this.getView().getModel( "imageTable" );
				entitySet	=	"/ImageSet";
				this.closegImagePopover();
				break;
			case "SourcingFilesUploader":
				modelTab	=	this.getView().getModel( "sourcingFile" );
				entitySet	=	"/SrcFileSet";
				this.closePopOver();
				break;
		}

		//	Build Filter for Article Number
		
			var filter 		= new sap.ui.model.Filter({ 
				path 	: 	"OBJNR",
				operator: 	sap.ui.model.FilterOperator.EQ,  
				value1 	: 	vArtNum
			});
		

		if ( vStatus === 201 || vStatus === 200 ) {
			oView.getModel( "CatMatService" ).read( entitySet, {
				filters: [ filter ],
				success: function( oData ) {

					//	Update Image Table Model
					modelTab.setData( oData.results );

					//	Success Message
					sap.m.MessageToast.show( oBundle.getText( "UPLOAD_SUCCESS" ) );
					
					if( id === "SourcingFilesUploader" ){
						var srcFile 	=	thisDetail.getView().getModel( "sourcingFile" ).getData(),
							FileTable	=	[],
							mfrnr		=	thisDetail._FilesUploadSourcing.mfrnr,
							field		=	"MFRNR";
							// if( thisDetail._artNumber.includes( "AF" ) ){
							// 	mfrnr			=	thisDetail._FilesUploadSourcing.sokey;
							// 	field			=	"SOKEY";
							// }else{
							// 	mfrnr			=	thisDetail._FilesUploadSourcing.mfrnr;
							// 	field			=	"MFRNR";
							// }
						for (var i = 0; i < srcFile.length; i++) {
					 		if( srcFile[i][field] === mfrnr){
					 			FileTable.push( srcFile[i] );
					 		}
						 	thisDetail.getView().getModel( "sourcingFileTable" ).setData( FileTable );
						 	
						 	thisDetail.updateSourcingTable(oView, vArtNum);
					 	}
					}
				 	thisDetail._BusyDialog.close();
				 	
				},
				error: function( oError ) {
					//	Free the View
					sap.m.MessageToast.show( JSON.parse(oError.responseText).error.message.value );
					thisDetail._BusyDialog.close();

				}
			});
		} else {
			uploadMsg	=	xmlDoc.getElementsByTagName("message")[0].childNodes[0].nodeValue;
			//	Free the View
			thisDetail._BusyDialog.close();

			//	Success Message
			sap.m.MessageToast.show( uploadMsg );
		}
	},
	
	updateSourcingTable: function( oView, vArtNum ){
		var modelTab	=	oView.getModel( "SourcingData" ),
			that		=	this,
			filter 		=	new sap.ui.model.Filter({ 
														path 	: 	"MATNR",
														operator: 	sap.ui.model.FilterOperator.EQ,  
														value1 	: 	vArtNum
													}),
			finish		=	[false,false],
			sourcingModel,
			statusModel;
		
		oView.getModel( "CatMatService" ).read( "/SourcingSet", {
			filters: [ filter ],
			success: function( oData ) {
				
				//	Update Image Table Model
				finish[0]	=	true;
				sourcingModel	=	 oData.results;
				that.refreshSourcingModel( finish, sourcingModel, statusModel );
				that._BusyDialog.close();

			},
			error: function( oError ) {
				//	Free the View
				sap.m.MessageToast.show( JSON.parse(oError.responseText).error.message.value );
				that._BusyDialog.close();

			}
		});
		oView.getModel( "CatMatService" ).read( "/StatutSet", {
			filters: [ filter ],
			success: function( oData ) {
				
				//	Update Image Table Model
				finish[1]	=	true;
				statusModel	=	oData.results;
				that.refreshSourcingModel( finish, sourcingModel, statusModel );
				that._BusyDialog.close();

			},
			error: function( oError ) {
				//	Free the View
				sap.m.MessageToast.show( JSON.parse(oError.responseText).error.message.value );
				that._BusyDialog.close();

			}
		});
	},
	
	refreshSourcingModel: function(  finish, sourcingModel, statusModel  ){
		if( !finish.includes( false ) ){
			this.getView().getModel( "SourcingData" ).setData( this.addStatusToSourcing( statusModel , sourcingModel ) );	
		}
	},
	
	/**
	 * On Type not allowed
	 * @param  {jQuery.Event} oEvent 
	 */
	uploaderTypeMissmatch: function( oEvent ) {
		var aFileTypes 			= oEvent.getSource().getFileType(),
			sSupportedFileTypes = aFileTypes.join(", "),
			oBundle 			= this.getView().getModel( "i18n" ).getResourceBundle();
		
		//	Check if file extention allowed
		jQuery.sap.each( aFileTypes, function(key, value) {
			aFileTypes[key] = "*." +  value;
		});
		
		//	Error Message
		sap.m.MessageToast.show(
			oBundle.getText( "UPLOAD_TYPE_MISSMATCH" , [
				oEvent.getParameter("fileType"), 
				sSupportedFileTypes
				]
			)
		);
	},
	
	recipeSearch: function( event ){
		var model	=	this.getView().getModel( "recipeFilter" ).getData(),
			table	=	this.byId( "recetteTable" );
			
		this.handleSearchTable( model, table );
	},
	ClearRecipeFilter: function(){
		this.getView().getModel( "recipeFilter" ).setData({});
		this.handleSearchTable( {} , this.byId( "recetteTable" ));
	},
	VolumeSearch: function(){
		var model	=	this.getView().getModel( "volumeFilter" ).getData(),
			table	=	this.byId( "volumeTable" );
			
		this.handleSearchTable( model, table );
		var totalModel	=	this.getView().getModel( "total" ),
			tableModel	=	this.getView().getModel( "volumeTable" ),
			line		,
			totalP		=	0,
			totalM		=	0,
			path		,
			items		=	table.getItems();
		for (var i = 0 ; i < items.length ; i++ ){
			path	=	items[i].getBindingContext( "volumeTable" ).getPath();
			line	=	tableModel.getProperty( path );
			totalP	=	Number( totalP ) + Number( line.QTITE );
			totalM	=	Number( totalM ) + Number( line.QTITM );
		}
		totalModel.setData( {	
								"totalP" : totalP.toFixed(3),
								"totalM" : totalM.toFixed(3) });
	},
	ClearVolumeFilter: function(){
		this.getView().getModel( "volumeFilter" ).setData({});
		this.VolumeSearch();
	},
	handleSearchTable: function( model, table ){
		var filters	=	[],
			date;
		if( model.APDEB ){
			var deb			=	model.APDEB.split( " - " )[0],
				fin 		=	model.APDEB.split( " - " )[1],
				filter		=	[],
				dateFilter	=	[],
				debFilter	=	[],
				finFilter	=	[];
			date	=	deb.split(".");
				
			deb 	=	date[2]	+	date[1]	+	date[0];
			date	=	fin.split( "." );
			fin 	=	date[2]	+	date[1]	+	date[0];
			//	Filter on date
			
			debFilter.push(	new sap.ui.model.Filter( "APDEB" , sap.ui.model.FilterOperator.LE , deb) );
			debFilter.push(	new sap.ui.model.Filter( "APFIN" , sap.ui.model.FilterOperator.GE , deb) );
			finFilter.push(	new sap.ui.model.Filter( "APDEB" , sap.ui.model.FilterOperator.LE , fin) );
			finFilter.push(	new sap.ui.model.Filter( "APFIN" , sap.ui.model.FilterOperator.GE , fin) );
			dateFilter.push(	new sap.ui.model.Filter( "APDEB" , sap.ui.model.FilterOperator.GE , deb) );	
			dateFilter.push(	new sap.ui.model.Filter( "APFIN" , sap.ui.model.FilterOperator.LE , fin) );
			filter.push(	new sap.ui.model.Filter( debFilter,true) );
			filter.push(	new sap.ui.model.Filter( finFilter,true) );
			filter.push(	new sap.ui.model.Filter( dateFilter,true) );
			if( table.getId().includes( "recette" ) ){
				filter.push(	new sap.ui.model.Filter( "APDEB" , sap.ui.model.FilterOperator.EQ , "" ) );
				filter.push(	new sap.ui.model.Filter( "APFIN" , sap.ui.model.FilterOperator.EQ , "" ) );
			}
			filters.push( new sap.ui.model.Filter(filter,false) );
			// date = model.APDEB.split( "-" );
			// if( date.length > 1 ){
			// 	model.APDEB	=	date[0] + date[1] + date[2];
			// }
			// filters.push(new sap.ui.model.Filter("APDEB", sap.ui.model.FilterOperator.GE, model.APDEB));
		}
		// if( model.APFIN ){
		// 	date = model.APFIN.split( "-" );
		// 	if( date.length > 1 ){
		// 		model.APFIN	=	date[0] + date[1] + date[2];
		// 	}
		// 	filters.push(new sap.ui.model.Filter("APFIN", sap.ui.model.FilterOperator.LE, model.APFIN));
		// }
		if( model.STATS ){
			filters.push(new sap.ui.model.Filter("STATS", sap.ui.model.FilterOperator.EQ, model.STATS));
		}
		if (filters.length > 0) {
			table.getBinding("items").filter(new sap.ui.model.Filter(filters, true));
		}else{
			table.getBinding("items").filter(null);
		}
	},
	
	onPressRecette: function( event ){
		var path	=	event.getSource().getParent().getBindingContext( "recipeTable" ).getPath(),
			line	=	this.getView().getModel( "recipeTable" ).getProperty( path ),
			frnum	=	line.RCNUM,
			ftver	=	line.RCVER,
			oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation"), // get a handle on the global XAppNav service
			hash = (oCrossAppNavigator && oCrossAppNavigator.hrefForExternal({
				target: {  
							semanticObject: "ZFTCatalogueRecette",
							action: "manage"
						 },
				 params: {
				 			"FRNUM": frnum,
				 			"FTVER": ftver
						}})) || ""; // generate the Hash to display a Supplier
		oCrossAppNavigator.toExternal({
										  target: {
													shellHash: hash
													}}); // navigate to Supplier application
						  
		
	},
	
	handleDialogSearch: function( value, name, binding ) {
		var Filter 	= new sap.ui.model.Filter( name, sap.ui.model.FilterOperator.EQ, value);
		binding.filter([Filter]);
	},
	
	handleFournisseurSearch: function(oEvent) {
		var sValue 		= oEvent.getParameter("value"),
			oBinding 	= oEvent.getSource().getBinding("items");
		
		this.handleDialogSearch( sValue, "MFRNR", oBinding);
	},
	
	onOpeGammeList: function(event) {
		// create value help dialog
		if (!this._CarteOpeListDialog) {
			this._CarteOpeListDialog = sap.ui.xmlfragment(
				"CatalogMat.Fragment.CarteOpeList",
				this
			);
			// Article Data model
			this.getView().setModel(new sap.ui.model.json.JSONModel(), "VHMenusSet");
			var service = this.getView().getModel("CatMatService"),
				thisDetail	=	this;
			service.read("/VHMenusSet", {
				success: function(oData) {
					thisDetail.getView().getModel("VHMenusSet").setData(oData.results);
				},
				error: function(error) {

				}
			});
			this.getView().addDependent(this._CarteOpeListDialog);
		}

		this._CarteOpeListDialog.open();
		var source	=	event.getSource().getId();
		if( source.includes( "newProduct" ) ){
			this._CarteOpeListDialog.Type	=	"newCarte";	
		}else{
			this._CarteOpeListDialog.Type	=	"existeCarte";	
		}
	},

	confirmOpeGamme: function(event) {
		var value = event.getParameter("selectedItem"),
			data;
		if( this._CarteOpeListDialog.Type	===	"newCarte" ){
			data	=	this.getView().getModel("NewProduct");
		}else{
			data	=	this.getView().getModel("articleData");
		}
		
		data.setProperty("/CTNUM", value.getDescription());
		data.setProperty("/DESCR", value.getTitle());
	},
	
	removeErrorState:function( event ){
		var source	=	event.getSource(),
			object	=	source.getMetadata().getName(),
			value;
		if( object.includes( "Select" ) ){
			value	=	source.getSelectedKey();
			if( value === "" ){
				source.addStyleClass("errorValueState");
			}else{
				source.removeStyleClass("errorValueState");
			}
		}else{
			value	=	source.getValue();
			if( value === "" ){
				source.setValueState( "Error" );
			}else{
				source.setValueState( "None" );
			}
		}
	},
	
	DuplicateIngredient: function() {
		if (!this._initDialog) {
			this._initDialog = sap.ui.xmlfragment("CatalogMat.Fragment.initNewArticleDialog", this);
			this.getView().addDependent(this._initDialog);
		}
		this.getView().getModel("NewProductStats").setProperty("/MEINS", false);
		var data	=	this.getView().getModel( "articleData" ).getData(),
			descp;
		if( data.MATNR.includes( "AF" ) ){
			descp	=	data.DESCP;
		}else{
			descp	=	"";
		}
		this.getView().getModel("NewProduct").setData({
			"MATNR": data.MATNR,
			"DESCP": descp,
			"ACNUM": "",
			"CTNUM": "",
			"MAKTX": data.MAKTX,
			"MEINS": data.MEINS,
			"SRCLC": false,
			"TARAP": data.TARAP,
			"DESFL": "",
			"ACNUM_DESCR" : ""
		});
		this._initDialog.open();
	},
	/**
	 * Close newProduct popUp
	 * and reset the init dialog
	 */
	onCloseInitDialog: function() {
		var newProduct = this.getView().getModel("NewProductStats");
		newProduct.setProperty("/DESCP", sap.ui.core.ValueState.Default);
		newProduct.setProperty("/CTNUM", sap.ui.core.ValueState.Default);
		newProduct.setProperty("/MAKTX", sap.ui.core.ValueState.Default);
		newProduct.setProperty("/MEINS", false);
		newProduct.setProperty("/TARAP", sap.ui.core.ValueState.Default);
		this.getView().getModel("NewProduct").setData({
			"MATNR": "",
			"DESCP": "",
			"ACNUM": "",
			"CTNUM": "",
			"MAKTX": "",
			"MEINS": "",
			"SRCLC": false,
			"TARAP": "",
			"DESFL": "",
			"ACNUM_DESCR" : ""
		});
		this._initDialog.close();
		this._initDialog.destroy();
		this._initDialog	=	undefined;
	},
	/**
	 * Confirm init dialog
	 * check if all the must values are populate
	 * if true nav to new article detail page
	 */
	onConfirmInitDialog: function() {
		var newProduct		=	this.getView().getModel("NewProduct"),
			newProductModel =	newProduct.getData(),
			navig			=	this.getView().getModel("NewProductStats").getProperty( "/NAVIG" ),
			that	=	this,
			service 		=	this.getView().getModel("CatMatService"),
			content			=	this._initDialog.getContent()[0].getAggregation( "form" ).getAggregation( "formContainers" )[0].getAggregation( "formElements" ),
			oFileUploader	=	content[7].getFields()[0],
			oBundle			=	this.getView().getModel("i18n").getResourceBundle(),
			check			=	false;
		that.getView().setBusy(true);
		if( newProductModel.MAKTX === "" ){
			content[1].getFields()[0].setValueState( "Error" );
			content[1].getFields()[0].setValueStateText( oBundle.getText( "THE_FIELD" ) + " '" + oBundle.getText( "ARTICLE_NAME" ) + "' " + oBundle.getText( "IS_REQUIRED" ) );
			check	=	true;
		}
		if( newProductModel.DESCP === "" ){
			check	=	true;
			content[2].getFields()[0].setValueState( "Error" );
			content[2].getFields()[0].setValueStateText( oBundle.getText( "THE_FIELD" ) + " '" + oBundle.getText( "DESCRIPTIF" ) + "' " + oBundle.getText( "IS_REQUIRED" ) );
		}
		if( newProductModel.ACNUM_DESCR.length === 0 || !newProductModel.ACNUM_DESCR ){
			check	=	true;
			content[3].getFields()[0].setValueState( "Error" );
			content[3].getFields()[0].setValueStateText( oBundle.getText( "THE_FIELD" ) + " '" + oBundle.getText( "BUYER" ) + "' " + oBundle.getText( "IS_REQUIRED" ) );
		}
		if( newProductModel.MEINS === "" ){
			check	=	true;
			content[5].getFields()[0].getItems()[0].addStyleClass("errorValueState");
		}
		if( newProductModel.TARAP === "" ){
			check	=	true;
			content[6].getFields()[0].setValueState( "Error" );
			content[6].getFields()[0].setValueStateText( oBundle.getText( "THE_FIELD" ) + " '" + oBundle.getText( "TARIFF_APPROACH" ) + "' " + oBundle.getText( "IS_REQUIRED" ) );
		}
		if( newProductModel.Files && ( newProductModel.DESFL === "" || !newProductModel.DESFL ) ){
			check	=	true;
			content[8].getFields()[0].setValueState( "Error" );
			content[8].getFields()[0].setValueStateText( oBundle.getText( "THE_FIELD" ) + " '" + oBundle.getText( "DESC_PHOTO" ) + "' " + oBundle.getText( "IS_REQUIRED_WHEN" ) );
		}
		if( check ){
			that.getView().setBusy(false);
			return;
		}else{
			delete newProductModel["__metadata"];
			delete newProductModel["DESCR"];
			var param = {
				method: "GET",
				async:	false,
				urlParameters: newProductModel,
				success: function(data) {
					if( oFileUploader.getValue() !== "" ){
						that.uploadPress(oFileUploader, data.MATNR, "I", oFileUploader.getValue(), "", newProductModel.DESFL);
					}
					//	Display message
					sap.m.MessageToast.show("L'article " + data.MATNR + " - " + data.MAKTX + " a  bien été créé");
					if (!data) {
						return;
					}
					that.getView().setBusy(false);
					that.onCloseInitDialog();
					if( navig ){
						var parametre		=	{ "Article": "(MATNR='" + data.MATNR +"',MFRNR='" + data.MFRNR + "')"};
						that.navigationTo("Detail", parametre, false);
					}
				},
				error: function(error) {
					//	Disable busy indicator
					that.getView().setBusy(false);
					
					//	Display message
					sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
				}
			};
	
			service.callFunction("/Article_Create", param);
		}
		
	}
});