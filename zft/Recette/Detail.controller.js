jQuery.sap.require( "sap/ui/model/Filter" );
jQuery.sap.require( "sap/ui/model/FilterOperator" );
jQuery.sap.require( "jquery.sap.resources" );
jQuery.sap.require( "sap/ui/Device" );
jQuery.sap.require( "sap/m/MessageBox" );
jQuery.sap.require( "sap/m/SplitContainer" );
jQuery.sap.declare(	"com.ODataFileUploader.Component");
jQuery.sap.require("sap.ui.unified.FileUploader");
jQuery.sap.require( "sap/m/MessageToast" );
jQuery.sap.require(	"CatalogRecette/util/Formatter" );
jQuery.sap.require( "sap/m/StandardListItem" );

sap.ui.controller(  "CatalogRecette.controller.Detail", {
	/**
	* Called when a controller is instantiated and its View controls (if available) are already created.
	* Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
	* @memberOf test.detail
	*/
	pageName	:	"",
	thisDetail	:	null,
	recipeType	:	null,
	Formatter : CatalogRecette.util.Formatter,
	onInit: function() {
		this.getView().addStyleClass( "sapUiSizeCompact" );
		thisDetail = this;
		this.InitModels();
		//	Routing
		this.router 	= sap.ui.core.UIComponent.getRouterFor(this);
		this.router.attachRoutePatternMatched( this.handleRouting , this);
		
		/**
		 * if the article is block for edit unlock the article without
		 * on close window/tab or refresh tab
		 */
		window.onbeforeunload = function (event) {
		    var oBundle 	= 	thisDetail.getView().getModel("i18n").getResourceBundle(),
			    message 	=	oBundle.getText( "WARNING_MESSAGE" );
		    if( thisDetail.getView().getModel( "Edit" ).getProperty( "/EditOn" ) ){
			    if (typeof event == 'undefined') {
			        event = window.event;
			    }
			    if (event) {
			    	// thisDetail.onLockEdit("U", thisDetail.getView().getModel( "articleData" ).getData().ArticleNumber, true);
			        event.returnValue = message;
			    }
			    return message;
			}
		}
		
		var that	=	this;
				// Register the view with the message manager
				sap.ui.getCore().getMessageManager().registerObject(this.getView(), true);
				var oMessagesModel = sap.ui.getCore().getMessageManager().getMessageModel();
				this._oBinding = new sap.ui.model.Binding(oMessagesModel, "/", oMessagesModel.getContext("/"));
				// this._oBinding.attachChange(function(oEvent) {
				// 	var aMessages = oEvent.getSource().getModel().getData();
				// 	for (var i = 0; i < aMessages.length; i++) {
				// 		if (aMessages[i].type === "Error" && !aMessages[i].technical) {
 			// 		}
				// 	}
				// });
		
	},
	
	/**
	 * Convenience method for getting the resource bundle.
	 * @public
	 * @returns {sap.ui.model.resource.ResourceModel} the resourceModel of the component
	 */
	getResourceBundle: function() {
		return this.getOwnerComponent().getModel("i18n").getResourceBundle();
	},
	
	InitModels: function(){
		// Model for edition article
		var oModel = new sap.ui.model.resource.ResourceModel( { bundleUrl:"./i18n/i18n.properties" } );
      	sap.ui.getCore().setModel(oModel, "i18n");
																	
		this.getView().setModel( new sap.ui.model.json.JSONModel({}),"helpModel");																	
																	
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"articleData" );

		this.getView().setModel( new sap.ui.model.json.JSONModel(),"volumeTab" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"volumeFilter" );

		this.getView().setModel( new sap.ui.model.json.JSONModel(),"ingredientTab" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"versionTable" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "articleAcheterSet" );

		this.getView().setModel( new sap.ui.model.json.JSONModel(),"texteTab" );

		this.getView().setModel( new sap.ui.model.json.JSONModel(),"tpvTab" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"enseigneTable" );	
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"calculateModel" );
		this.initCalculateModel();
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "journalTable" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel([]),"totalValor" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"imageTable" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"StatList" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"statusModel" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"articleFileTable" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"cartesModel" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel( { "TITRE"	:	"None",
																	"FAMIL"	:	false	} ), "NouvelleRecette" );
		
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(),"AddTPV" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "articleSale" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "warningModel" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel( {	
																		"totalP"	:	0,
																		"totalM"	:	0 }), "total" );

		this.getView().setModel( new sap.ui.model.json.JSONModel( { "descriptionSate"	:	"None",
																	"urlState"			:	"None"		} ), "UploadImage" );

	},
	handleRouting: function( event ){
		// this.getView().rerender();
	
		this.pageName 		=	event.getParameter( "name" );
		this.byId( "iconTabDetail" ).setSelectedKey( "infoGeneralTab" );
		// this.fullScreen();
		var recette 		=	event.getParameter("arguments").Recette,
			msgArea			=	this.getView().byId( "msgArea" );
			msgArea.removeAllItems();
		// this.getView().byId( "totalLabel" ).setText( "" );
		// this.getView().byId( "totalValue" ).setText( "" );

		if( this.pageName === "Overview" ) {
			if( this.getView().getModel( "Edit" ).getProperty( "/EditOn" ) ){
				this.onEdit();
			}
			return;
		}
		else if( this.pageName === "NouvelleRecette" ){
			this.getView().getModel( "Edit" ).setProperty( "/NewRecipe", true );
			this.recipeType = recette;
			recette 	=	"(FTVER='',FRNUM='$')";
			this.readModel( recette );
			// this.getView().getModel( "QuickFilter" ).setData( this.getView().getModel( "QuickFilter" ).getData() );
		}
		else if( this.pageName === "DuplicationRecette" ){
			this.recipeType = recette.split(")")[1];
			recette 		= recette.split(")")[0] + ")";
			this.readModel( recette );
			this.getView().getModel( "Edit" ).setProperty( "/NewRecipe", true );
			this.getView().getModel( "Edit" ).setProperty( "/Active", this.getView().getModel( "articleData" ).getProperty( "/ISFIC" ) );
			// this.getView().getModel( "QuickFilter" ).setData( this.getView().getModel( "QuickFilter" ).getData() );
		}else {
			this.getView().getModel( "Edit" ).setProperty( "/NewRecipe", false );
			this.readModel( recette );
			this.getView().getModel( "Edit" ).setProperty( "/Active", this.getView().getModel( "articleData" ).getProperty( "/ISFIC" ) );
			// this.getView().getModel( "QuickFilter" ).setData( this.getView().getModel( "QuickFilter" ).getData() );
		}
		
	},
	
	
	/**
	 *	This function check if this article is block for edit by the server
	 * 	Call by onEdit function and call the Lock_Unlock_Article server function
	 */
	onLockEdit: function ( actionCode , articleNumber , OEdit , model){
		var that			=	this;
		if( !window.origin.includes( "webide" )  && this.RCNUM !== "$" && this.pageName === "Detail" ){
			that.getView().setBusy( true );
			
			jQuery.ajax({
	    		url: 			"/sap/bc/ZMOB_LOCK_SRV?action=" + actionCode + "&object=CATREC&objectKey=" + articleNumber,  
			    type: 			"POST",
	            contentType: 	"application/json",
    			async:			false,
	
	
			    success: function (result) { 
			     that.getView().setBusy( false );
				if( !result ){
					return;
				}
				// Success if the article isn't open for edit by another user
				// Lock or unlock the article for edit
				if( result.Type === "S" ) {
					if( !OEdit ){
						model.setProperty( "/delete" 	, "Delete" );
						var vModel	=	that.getView().getModel( "versionTable" ),
							vTable	=	that.byId( "versionTable" ),
							index	=	vTable.getSelectedIndex(),
							path	=	vTable.getContextByIndex( index ).getPath();
						if( (	that.getView().getModel( "articleData" ).getProperty( "/FRNUM" ) && 
								that.getView().getModel( "articleData" ).getProperty( "/FRNUM" ).includes( "SR" ) ) ||
							(	Number( vModel.getProperty( path + "/APDEB" ) ) > Number( that.toDateString( new Date() ) ) ) ){
							model.setProperty( "/deleteVersion", "Delete" );
						}
						if( that.editableIng ){
							that.byId( "removeVersion" ).setVisible( true );
						}
					}else{
						model.setProperty( "/delete" 	, "None" );
						// model.setProperty( "/EditableIng", false );
						model.setProperty( "/deleteVersion", "None" );
						that.byId( "removeVersion" ).setVisible( false );
					
					}
				}	
				// Error if the article is lock for edit by another user
				// can't lock or unlock this article for edit 
				else{	
					that.onEdit( "lock" );
					sap.m.MessageToast.show( result.MessageText );
					// reset the UI edit mode
					
					
				}
			    },  
			    error: function (e) {  
		    		if( e.status === 400 ){
		    			that.onLockEdit( actionCode , articleNumber , OEdit , model);
		    		}else{
			    		// Disable busy indicator
						that.getView().setBusy( false );
						that.onEdit( "lock" );
						// that.getView().getModel( "Edit" ).setProperty( "/EditOn" , false );
						// that.getView().getModel( "Edit" ).setProperty( "/buttonOn" , true );			
						
						//	Display message
						sap.m.MessageToast.show( e.statusText );
		    		}
				}
			});  
		}
	},
		
	// initStatusModel:function( isfic ){
 //       if( this.pageName !== "Detail" ){
 //       	if( isfic ){
 //       		this.getView().getModel( "articleData" ).setProperty( "/STATS" , "10");
 //       	}else{
 //       		this.getView().getModel( "articleData" ).setProperty( "/STATS" , "00");
 //       	}
 //       	this.byId( "StatusId" ).setEnabled( false );
 //       }
	// },
	
	DuplicateActionSheet : function (oEvent) {
		var oButton 		=	oEvent.getSource(),
			currentView		=	this.getView(),
			model			=	currentView.getModel( "articleData" ).getData(),
			version			=	currentView.getModel( "versionTable" ).getData(),
			ingredients		=	currentView.getModel( "ingredientTab" ).getData(),
			ftver			=	null,
			isfic			=	null,
			cnfic			=	null;

		// create action sheet only once
		if (!this._actionSheet) {
			this._actionSheet = sap.ui.xmlfragment(
				"CatalogRecette.Fragment.DetailDuplicateActionSheet",
				this
			);
			this.getView().addDependent(this._actionSheet);
		}
	
		this._actionSheet.openBy(oButton);
		
		this._actionSheet.setTitle("Duplication de recette");
		
		isfic		=	model.ISFIC;
		cnfic		=	model.CNFIC;
		
		if( isfic ){
			jQuery.sap.each( version , function( index , item ) {
				if( item.SRTFT ){
					ftver	=	item.FTVER;
				}
			});    
			if( ftver	===	null ){
				ftver	=	version[ version.length - 1 ].FTVER;
			}
		}else{
			var date	=	Number( this.toDateString( new Date() ) );
			jQuery.sap.each( version , function( index , item ) {
				if( Number( item.APDEB ) < date && Number( item.APFIN ) > date ){
					ftver	=	item.FTVER;
					return;
				}
			});    
			if( ftver	===	null ){
				ftver	=	version[ version.length - 1 ].FTVER;
			}
		}
		var ingModel	=	this.getView().getModel( "ingredientTab" ).getData(),
			cnIng		=	false;
		ingModel.forEach( function( item ){
			if( item.FTVER	===	ftver ){
				cnIng	=	true;
			}
		});
		if( isfic ){
			// cnfic	=	false;
			// jQuery.each( ingredients , function( index, item ){
			// 	if( item.FTVER === ftver && ( item.MATNR.includes( "AF" ) || item.MATNR.includes( "SR" ) ) ){
			// 		cnfic	=	true;
			// 		return;
			// 	}
			// });
			if( cnfic || !cnIng ){
				this._actionSheet.getAggregation("buttons")[0].setVisible( false );
			}else{
				this._actionSheet.getAggregation("buttons")[0].setVisible( true );
			}
		}else{
			this._actionSheet.getAggregation("buttons")[0].setVisible( true );
		}
	},
	
	/**
	 * Initialistion of newproduct popUp
	 */
	onNewRecipe: function( event ){
		var source			=	event.getSource(),
			buttonId		=	source.getId(),
			item			=	this.getView().getModel( "articleData" ).getData(),
			recettePath 	=	"(FRNUM='" + item.FRNUM + "',FTVER='" + item.FTVER + "')",
			param			=	{"Recette"	:	recettePath + this.defineRecipeType( buttonId )},
			routeName		=	"DuplicationRecette";
				
	 	this.navigationTo( routeName, param, false );
	},
	goNextLine: function( value ){
		var size	=	value.length;
		if( size > 132 ){
			var result	= '',
				temp,
				check	=	false,
				index;
			while (value.length > 0) {
				while (value.length > 0 && !check ) {
					temp	=	value.substring(0, 132);
					index	=	temp.indexOf( "\n" );
					if( index === -1 ){
						check	=	true;
					}else if( index === 0 ){
						value = value.substring(1);
					}
					else{
						result += value.substring(0,index + 2);
						value = value.substring(index + 2);
						check	=	false;
					}
				}
				result += value.substring(0, 132);
				if( value.length > 132 ){
					result += '\n';
				}
				value = value.substring(132);
				check	=	false;
			}
			return result;
		}else{
			return value;
		}
	},
	
	defineRecipeType: function( buttonId ){
		if( buttonId.includes( "FicheTechnique" ) ){
				return	"FT";
			}else{
				return	"SR";
			}
	},
		
	addDuplicateVersion: function( versionDuplicate ){
		var version		=	this.getView().getModel( "versionTable" ).getData(),
			ingredient	=	this.getView().getModel( "ingredientTab" ).getData(),
			duplicate	=	versionDuplicate.getData(),
			temp		=	[],
			ingTemp		=	[],
			date		=	this.toDate( duplicate[0].APDEB );
			date.setDate( date.getDate() - 1 );
		if( version.length === 1 ){
			if( Number( duplicate[0].APDEB ) <  Number( version[0].APFIN ) ){
					version[0].APFIN	=	this.toDateString( date );
			}
			temp.push( version[0] );
			temp.push( duplicate[0] );
		}else{
			for (var i=0; i<version.length; i++) {
				if( Number( duplicate[0].APDEB ) >  Number( version[i].APDEB ) ){
					if( Number( duplicate[0].APDEB ) >  Number( version[i].APFIN ) ){
						temp.push( version[i] );
					}else{
						version[i].APFIN	=	this.toDateString( date );
						duplicate[0].FTVER		=	i + 2 + "";
						temp.push( version[i] );
						temp.push( duplicate[0] );
					}
				}
			}
		}
		this.getView().getModel( "versionTable" ).setData( temp );
		for ( i=0; i<ingredient.length; i++) {
			for (var j=0; j<temp.length; j++) {
				if( ingredient[i].FTVER === temp[j].FTVER ){
					ingTemp.push( ingredient[i] );
					break;
				}
			}
		}
		for ( i=0; i<duplicate[1].length; i++) {
			duplicate[1][i].FTVER	=	duplicate[0].FTVER;
			ingTemp.push(duplicate[1][i]);
		}
		this.getView().getModel( "ingredientTab" ).setData( ingTemp );
		this.byId( "versionTable" ).setSelectedIndex( temp.length - 1 );
		versionDuplicate.setData( {} );
		this.onEdit();
				
	},
	
	onPressArticle: function( event ) {
		var frnum	=	event.getSource().getText(),
			appPath,
			param;
		if( frnum.startsWith( "FT" ) || frnum.startsWith( "SR" ) ){
			appPath	=	"ZFTCatalogueRecette";
			var temp	=	frnum.split( " - " ),
				ftver	=	"";
			frnum	=	temp[0];
			if( temp.length > 1 ){
				ftver	=	Number( temp[1] ) + "";
			}
				
			param	=	{
				 			"FRNUM": frnum, "FTVER": ftver
						};
		}else{
			appPath	=	"ZFTCatalogueMatPrem";
			param	=	{
				 			"MATNR": frnum
						};
		}
		var oCrossAppNavigator = sap.ushell.Container.getService("CrossApplicationNavigation"), // get a handle on the global XAppNav service
			hash = (oCrossAppNavigator && oCrossAppNavigator.hrefForExternal({
				target: {  
							semanticObject: appPath,
							action: "manage"
						 },
				 params: param
				
			})) || ""; // generate the Hash to display a Supplier
		oCrossAppNavigator.toExternal({
										  target: {
													shellHash: hash
													}}); // navigate to Supplier application
	},

	/**
	 * routing to the article's detail view
	 */
	NavToView: function( event ) {
		
		var servPath	=	event.getParameter("listItem").getBindingContext( "CatRectService" ).getPath().split("Set")[1],
			param		=	{ "Recette": servPath };
		this.getView().getModel( "enseigneTable" ).setData([]);
		//Routing
		this.navigationTo( "Detail", param, false );

	},
	
	 /* Navigate to detail page
	 *
	 * @param      {<type>}  Page       The page
	 * @param      {<type>}  Parameter  The Article Number
	 * @param      {<type>}  Bool       false
	 */
	navigationTo: function ( Page, Parameter, Bool ) {
		var router 			= 	sap.ui.core.UIComponent.getRouterFor( this.getView() );
		router.navTo( Page, Parameter, Bool );
	},
	
	_initNewRecette: function( oData ) {
		oData.ERDAT	= this.toDateString( new Date() );   

		// if( !( this.recipeType === "FT" && oData.ISFIC	===	true ) ){
		// 	oData.RC2IM.results	=	[];
		// }
		if( this.recipeType === "FT" ){
			if( oData.ISFIC ){
				oData.SRDUP			=	oData.FRNUM;	
			}
			oData.ISFIC				=	false;
			oData.AEDAT				=	this.toDateString( new Date() ); 
			oData.STATS				=	"00";
			oData.RC2ST.results		=	[{	
										SRNUM	:	"$",
										SRVER	:	"",
										STATS	:	"00",
										VTEXT	:	"FT - Statut initial"
										}];
		}else{
			oData.ISFIC				=	true;
			oData.AEDAT				=	"";
			oData.STATS				=	"10";
			oData.RC2ST.results		=	[{	
											SRNUM	:	"$",
											SRVER	:	"",
											STATS	:	"10",
											VTEXT	:	"SR - Initial"
											}];
		}
		oData.FRNUM			=	"";
		oData.RC2VL.results	=	[];
		oData.CARTS			=	"";

		return oData;
	},
	calculateChange: function(){
		this.getView().getModel( "totalValor" ).setData( [] );	
	},
	_InitSelectVersion: function( version ){
		var versionModel = this.getView().getModel( "versionTable" ).getData();
		if( version === "" || versionModel.length === 1 ){
			this.byId( "versionTable" ).setSelectedIndex(0);
			var path	=	this.byId( "versionTable" ).getContextByIndex(0).getPath();
			version 	=	this.getView().getModel( "versionTable" ).getProperty( path + "/FTVER" );
		}else{
			for (var i=0; i<versionModel.length; i++) {
				if( versionModel[i].FTVER === version ){
					this.byId( "versionTable" ).setSelectedIndex(i);
					break;
				}
			}
		}
		this.byId( "ingredientTable" ).getBinding("items").filter( new sap.ui.model.Filter( "FTVER" , sap.ui.model.FilterOperator.EQ , version ) );
		if( this.pageName !==	"Detail" ){
			this.getView().getModel( "Edit" ).setProperty( "/TotalValo", "" );	
		}
	},
	
	readModel: function ( article ) {
		var service 		=	this.getView().getModel( "CatRectService" ),
			thisDetail		=	this,
			version,
			articlePath		=	article.split("'"),
			versionDuplicate=	this.getView().getParent().getParent().getParent().getModel( "DuplicateVersion" ),
			msgArea 	= this.getView().byId( "msgArea" );
		thisDetail.getView().setBusy( true );
		if( articlePath[3].length > 3 ){
			version = articlePath[1];
		}else{
			version = articlePath[3];
		}
		
		service.read( "/RecetteSet" + article  , {
			urlParameters: 	"$expand=RC2IN,RC2VR,RC2TX,RC2EN,RC2TP,RC2VL,RC2IM,RC2ST,RC2SF,RC2HS",
			success: function ( oData ) {
				
				thisDetail.getView().getModel( "totalValor" ).setData([]);
				var textModel,
					isfic				=	null,
					recetteType			=	"",
					frnum				=	null;
				thisDetail.getView().getModel( "Edit" ).setProperty( "/TotalValo", "" );
				if( thisDetail.recipeType === "SR" ){
					recetteType			= "Simulation recette";

					//	Filtre pour statut
					// isfic	=	 new sap.ui.model.Filter("ISFIC" , sap.ui.model.FilterOperator.EQ , true );
				} else {
					recetteType			= "Fiche technique";

					//	Filtre pour statut
					// isfic	=	  new sap.ui.model.Filter("ISFIC" , sap.ui.model.FilterOperator.EQ , false ) ;
				}
				
				thisDetail.RCNUM	=	oData.FRNUM;
				switch( thisDetail.pageName ) {
					case "Detail":
					//	Application des filtres pour statut
					frnum	=	 new sap.ui.model.Filter("FRNUM" , sap.ui.model.FilterOperator.EQ , oData.FRNUM );
				
						textModel	=	oData.RC2TX.results;
						if( oData.ISFIC ){
							thisDetail.recipeType	=	"SR";
						}else{
							thisDetail.recipeType	=	"FT";
						}
						break;
					case "DuplicationRecette":
						isfic	= oData.ISFIC;
						oData	= thisDetail._initNewRecette( oData );
						textModel	=	oData.RC2TX.results;
						oData.DTCOM = 	"";
						oData.DLCSC = 	"";
						oData.PRIXI =	"0.000";
						oData.BRGEW	=	"0.000";
						oData.AENAM =	"";
						if(thisDetail.recipeType	===	"SR"){
							oData.ERNAM =	"";
							oData.AEDAT =	"";
						}
						
						oData.RC2TP.results 	=	[];
						
						// jQuery.sap.each( oData.RC2EN.results , function( index , item ) {
						// 	item.ACTIV = false;
						// });
						
						var tab		=	oData.RC2VR.results,
							temp	=	[],
							activ	=	false,
							futur	=	false,
							pass	=	false,
							tDate	=	new Date(),
							date	=	thisDetail.toDateString( tDate ),
							ingTab	=	oData.RC2IN.results,
							ingTemp	=	[];
							
						//	Recuperation de la version en cours
						if( !isfic ){
							for (var i=0; i<tab.length; i++) {
								if( Number(tab[i].APFIN) < Number( date )  ){
									pass	=	tab[i];
								}
								if( Number(tab[i].APDEB) <= Number( date ) && Number(tab[i].APFIN) >= Number( date )  ){
									activ	=	tab[i];									
									break;
								}
							}
							for ( i = tab.length - 1; i >= 0 ; i--) {
								if( Number(tab[i].APDEB) > Number( date )  ){
									futur	=	tab[i];
								}
							}
							if( activ ){
								activ.APDEB	=	thisDetail.toDateString( tDate );
								activ.APFIN	=	"99991231";
								temp.push( activ );
							}else if( futur ){
								futur.APDEB	=	thisDetail.toDateString( tDate );
								futur.APFIN	=	"99991231";
								temp.push( futur );
							}else{
								pass.APDEB	=	thisDetail.toDateString( tDate );
								pass.APFIN	=	"99991231";
								temp.push( pass );
							}
									
									
									
						}else{
							var check	=	false;
							for (var j = 0; j < tab.length; j++) {
								if( tab[j].SRTFT  ){
									tDate.setDate(tDate.getDate() );
									tab[j].APDEB	=	thisDetail.toDateString( tDate );
									tab[j].APFIN	=	"99991231";
									temp.push( tab[j ] );
									check = true;
									break;
								}
							}
							if( !check ){
								var index	=	tab.length - 1;
								tDate.setDate(tDate.getDate() );
								tab[index].APDEB	=	thisDetail.toDateString( tDate );
								tab[index].APFIN	=	"99991231";
								temp.push( tab[index] );
							}
						}

						//	Recuperation des ingredients de la version en cours
						if ( temp.length > 0 ) {
							oData.RC2VR.results = temp;	
						
							for (var j=0; j<ingTab.length; j++) {
								if( temp[0].FTVER	===	ingTab[j].FTVER ){
									ingTemp.push(ingTab[j]);
								}
							}
							oData.RC2IN.results	= ingTemp;
						} else {
							date				= new Date();
							oData.RC2VR.results[0].APDEB = thisDetail.toDateString( new Date( date.setDate(date.getDate() + 1) ) );
							oData.RC2VR.results[0].APFIN = "99991231";
							temp[0]		=	oData.RC2VR.results[0];
						}							
						 for( i = 0 ; i < oData.RC2EN.length ; i++) {
							oData.RC2EN[i].FRNUM	=	"$";
						} 
						oData.TITRE	+= " - " + temp[0].DESCR;
						break;
					case "NouvelleRecette":
						oData	= thisDetail._initNewRecette( oData );

						//	Nouvelle version (J+1 -> 31.12.9999)
						var date		=	new Date();
						textModel	=	[{	FRNUM	:	"",
											MATERL	:	"",
											MODOP	:	"",
											PREPAR	:	"",
											PTCRQ	:	""}];
						// oData.RC2VR.results			 = [];
						oData.RC2VR.results[0].APDEB	=	thisDetail.toDateString( new Date( date.setDate(date.getDate() ) ) );
						oData.RC2VR.results[0].APFIN	=	"99991231";
						thisDetail.getView().getModel( "Edit" ).setProperty( "/TotalValo", "" );
						break;
				}
				
				//	2. Mise a jour des modeles
				thisDetail.getView().getModel( "articleData" ).setData( oData );
				// thisDetail.initStatusModel( isfic );
				thisDetail.setTotalVolum( oData.RC2VL.results );
				thisDetail.getView().getModel( "articleFileTable" ).setData( oData.RC2SF.results );
				thisDetail.setCarteList( oData.RC2VL.results );
				thisDetail.getView().getModel( "enseigneTable" ).setData( thisDetail.enseigneTree( oData.RC2EN.results ) );
				thisDetail.byId( "Table" ).expandToLevel(1);
				thisDetail.getView().getModel( "versionTable" ).setData( oData.RC2VR.results );
				thisDetail.getView().getModel( "ingredientTab" ).setData( oData.RC2IN.results );
				thisDetail.getView().getModel( "texteTab" ).setData( textModel );
				thisDetail.getView().getModel( "tpvTab" ).setData( oData.RC2TP.results );
				thisDetail.getView().getModel( "volumeTab" ).setData( oData.RC2VL.results );
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
				thisDetail.handleVolumeSearch();                
				thisDetail.getView().getModel( "imageTable" ).setData( oData.RC2IM.results );
				thisDetail.getView().getModel( "StatList" ).setData( oData.RC2ST.results );
				thisDetail.getView().getModel( "journalTable" ).setData( oData.RC2HS.results );
				
				if( oData.RC2IN.results.length	!==	0 ){
					thisDetail.editIng	=	true;
				}
				
				//	Total
				// if( oData.RC2IN.results.length > 0 ) {
				// 	if( oData.RC2IN.results[oData.RC2IN.results.length - 1].FRNUM === "" ) {
				// 		thisDetail.getView().byId( "totalLabel" ).setText( oData.RC2IN.results[oData.RC2IN.results.length - 1].MAKTX );
				// 		thisDetail.getView().byId( "totalValue" ).setText( oData.RC2IN.results[oData.RC2IN.results.length - 1].RLVAL );	
				// 	}
				// }

				//	3. UI	
				var pageTitle			=	"";
				

				
				switch( thisDetail.pageName ) {
					case "Detail": 
						thisDetail.byId( "versionTable" ).setSelectedIndex( -1 );
						thisDetail._InitSelectVersion(version);
						break;
					case "DuplicationRecette":
						//	Selection de la premiere version
						thisDetail._InitSelectVersion(version);
						pageTitle		= recetteType + "  dupliquée de " + article.split( "'" )[1];
						thisDetail.byId( "DetailPage" ).setTitle( pageTitle );
						thisDetail.onEdit();
						break;
					case "NouvelleRecette":
						thisDetail.byId( "versionTable" ).setSelectedIndex( 0 );
						pageTitle		= "Nouvelle " + recetteType;
						thisDetail.byId( "DetailPage" ).setTitle( pageTitle );
						thisDetail.onEdit();
						break;
				}

				if( JSON.stringify( versionDuplicate.getData() ) !== JSON.stringify({}) ){
					var ftver				=	Number(oData.RC2VR.results[ oData.RC2VR.results.length - 1 ].FTVER) + 1 + "";
					versionDuplicate.setProperty( "/0/FTVER" , ftver);
					for ( i = 0; i < versionDuplicate.getData()[1].length ; i++) {
						versionDuplicate.setProperty( "/1/" + i + "/FTVER" , ftver);
					}
					thisDetail.addDuplicateVersion( versionDuplicate );
				}
				thisDetail.getView().setBusy( false );
				// thisDetail.handleSearch();
				thisDetail.initCalculateModel();
				

			},
			error: function ( error ) {
			 	thisDetail.getView().setBusy( false );
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
	
	readHistory: function( frnum, service ){
		var filter			=	[ new sap.ui.model.Filter( "PRNUM", sap.ui.model.FilterOperator.Contains, frnum ) ],
			historyModel	=	this.getView().getModel( "journalTable" );
			
      	service.read( "/HistorySet",{   
  			filters: filter ,
			success: function( oData ) {
        		historyModel.setData( oData.results );
            },
            error: function( error ) {
            }
	    });	
	},
	
	enseigneTree: function( model ){
		var articleTab 	= model.reduce( function( result , item ) {
									if( !result[item.VKORG] ) {
										result[item.VKORG]			=	{};
										result[item.VKORG].GAMTX	=	item.ORGTX;
										result[item.VKORG].ACTIV	=	item.ACTIV;
										result[item.VKORG].items	=	[];
                                    }
									result[item.VKORG].items.push( item );
									return result;
								} , {});
		var data 	=	{};

		for (var key in articleTab) {
			if( !data.items ){
		  		data.items = [];
		  	}
				data.items.push( articleTab[key]);  	
		}
		return data;
	},
	
	selectAllEnseigne: function( event ){
		var model	=	this.getView().getModel( "enseigneTable" ).getData(),
			path	=	event.getSource().getParent().getBindingContext( "enseigneTable" ).getPath(),
			pathTab	=	path.split( "/" ),
			first	=	Number( pathTab[2] ),
			activ	=	model.items[ first ].ACTIV,
			sec 	=	"t";
			
		if( pathTab.length > 3 ){
			sec	=	Number( pathTab[4] );
		}
		
		if( isNaN( sec ) ){
			jQuery.sap.each( model.items[ first ].items , function( index , item ) {
				item["ACTIV"]	=	activ;
			});	
		}else{
			if( model.items[ first ].items[ sec ].ACTIV ){
				var check	=	true;
				jQuery.sap.each( model.items[ first ].items , function( index , item ) {
					if( !item["ACTIV"] ){
						check	=	false;
						return;
					}
				});	
				model.items[ first ].ACTIV	=	check;
			}else{
				model.items[ first ].ACTIV = false;
			}
		}
	},
	
	setCarteList: function( model ){
		var crtList	=	[];
		for (var i=0; i<model.length; i++) {
			crtList.push( { CTNUM	:	model[i].CTNUM,
							DESCR	:	model[i].DESCR} );
		}	
		this.getView().getModel( "cartesModel" ).setData( crtList );
	},
	
	setTotalVolum: function( model ){
		var edit	=	this.getView().getModel( "Edit" ),
			period	=	0,
			mensuel	=	0;
		for (var i=0; i<model.length; i++) {
			period	=	period + Number( model[i].VLPER );
			mensuel	=	mensuel + Number( model[i].VLMEN );
		}
		edit.setProperty( "/TotalPeriod", period );
		edit.setProperty( "/TotalMensuel", mensuel );
	},

	/**
	 * After list data is available, this handler method updates the
	 * master list counter and hides the pull to refresh control, if
	 * necessary.
	 * @param {sap.ui.base.Event} oEvent the update finished event
	 * @public
	 */
	onUpdateFinished: function(oEvent) {
		var sTitle;

		// Update the master list object counter after new data is loaded
		// only update the counter if the length is final
		if ( this.byId( "masterList" ).getBinding( "items" ).isLengthFinal()) {
			sTitle		= this.getResourceBundle().getText( "RECETTE_HEADER_MASTER" , [oEvent.getParameter("total")] );
			this.getView().getModel( "Edit" ).setProperty( "/MasterHeader" , sTitle );
		}
	},
	
	onUpdateIngredientFinished: function(oEvent) {
		var sTitle;

		// Update the master list object counter after new data is loaded
		// only update the counter if the length is final
		if ( this.byId( "ingredientTable" ).getBinding( "items" ).isLengthFinal()) {
			sTitle		= this.getResourceBundle().getText( "INGREDIENT_TAB" , [oEvent.getParameter("total")] );
			this.getView().getModel( "Edit" ).setProperty( "/IngredientTab" , sTitle );
		}
	},
	
	SelectActiveVersion:function( event ){
		var source	=	event.getSource(),
			row 	=	source.getAggregation("items")[0];
		if( row ){
			var	cell	=	row.getAggregation("cells")[0],
				version	=	row.getAggregation("cells")[3].getText(),
				filter	=	new sap.ui.model.Filter( "FTVER" , sap.ui.model.FilterOperator.EQ , version );
			cell.setSelected( true );
			this.byId( "ingredientTable" ).getBinding("items").filter( filter );   
			this.version = version;
		}
	},
	
	setWarningModel: function( version ){
		var model	=	this.getView().getModel( "ingredientTab" ).getData(),
			temp	=	[],
			text;
		
		model.forEach( function( item ){
			if( item.FTVER === version && ( ( item.TWARN && item.TWARN !== "" ) || ( item.STATS === "50" || item.STATS === "1" )  ) ){
				if( item.TWARN && item.TWARN !== ""  ){
					text	=	item.TWARN;
				}else{
					text	=	item.TSTAT;
				}
				temp.push( {
								MATAC	:	item.MATAC,
								TSTAT	:	text
							});
			}	
		});
		this.getView().getModel( "warningModel" ).setData( temp );
	},
	
	closeWarningPopover: function(){
		this._warningPopover.close();
	},
	
	SelectVersion:function( event ){
		var source			=	event.getParameter( "rowContext" ),
			selectedIndex	=	event.getSource().getSelectedIndex(),
			edit			=	this.getView().getModel( "Edit" );
		if( selectedIndex > -1 ){
			var path	=	source.getPath().split("/")[1],
				model	=	this.getView().getModel( "versionTable" ).getData(),
				total	=	this.getView().getModel( "totalValor" ).getData(),
				version	=	model[ path ].FTVER,
				check	=	true,
				filter	=	new sap.ui.model.Filter( "FTVER" , sap.ui.model.FilterOperator.EQ , version );
				this.byId( "ingredientTable" ).getBinding("items").filter( filter );
			this.version = version;
			this.setWarningModel(version);
			for(var i=0; i<total.length; i++) {
				if( total[i].FTVER ===	version ){
					// this.getView().byId( "totalLabel" ).setText( total[i].MAKTX );
					// this.getView().byId( "totalValue" ).setText( total[i].RLVAL );	
					edit.setProperty( "/TotalValo", total[i].RLVAL );
					check	=	false;
				}
			}       
			if( check ){
				// this.getView().byId( "totalLabel" ).setText( "" );
				// this.getView().byId( "totalValue" ).setText( "" );	
				edit.setProperty( "/TotalValo", "" );
			}
			
			if( this.getView().getModel( "articleData" ).getProperty( "/FRNUM" ).includes( "SR" )){
				if( edit.getProperty( "/EditOn" ) ){
					this.editableIng	=	true;
					edit.setProperty( "/EditableIng", true );
					edit.setProperty( "/deleteVersion", "Delete" );	
				}else{
					this.editableIng	=	true;
					edit.setProperty( "/EditableIng", false );
					edit.setProperty( "/deleteVersion", "None" );
				}
			}else{
				var stats	=	this.getView().getModel( "articleData" ).getProperty( "/STATS" ),
					date	=	Number( this.toDateString( new Date() ) );
					
				this.setEditableIng( edit, model, path, date, stats );
				// if( edit.getProperty( "/EditOn" ) && 
				// 	(	Number( model[ path ].APDEB ) >  date || 
				// 		(	
				// 			Number( stats ) <= 12 &&
				// 			Number( model[ path ].APDEB ) <  date	&&	
				// 			Number( model[ path ].APFIN ) >  date 
				// 		) 
				// 	)){
				// 	this.editableIng	=	true;
				// 	edit.setProperty( "/EditableIng", true );
				// 	edit.setProperty( "/deleteVersion", "Delete" );
				// }else{
				// 	this.editableIng	=	false;
				// 	edit.setProperty( "/EditableIng", false );
				// 	edit.setProperty( "/deleteVersion", "None" );
				// }
				if( this.getView().getModel( "articleData" ).getData().ISFIC  ){
					edit.setProperty( "/Active", false );
				}else if( Number( model[ path ].APDEB ) < Number( this.toDateString( new Date() ) ) 
					&& Number( model[ path ].APFIN ) >= Number( this.toDateString( new Date() ) ) ){
					edit.setProperty( "/Active", true );
					
				}else{
					edit.setProperty( "/Active", false );
				}
				if( edit.getProperty( "/EditOn") && !edit.getProperty( "/Active" )){
					this.byId( "removeVersion" ).setVisible( true );
				}else{
					this.byId( "removeVersion" ).setVisible( false );
				}
			}
			this.Calculate();
		}else{
			edit.setProperty( "/TotalValo", "" );
			this.byId( "ingredientTable" ).getBinding("items").filter( new sap.ui.model.Filter( "FTVER" , sap.ui.model.FilterOperator.EQ , "" ) );
		}
	},
	
	changeRetenu: function ( event ){
		var select	=	event.getParameter( "selected" ),
			path	=	event.getSource().getParent().getBindingContext( "versionTable" ).getPath().split( "/" )[1],
			model	=	this.getView().getModel( "versionTable" ).getData();
		if( select ){
			jQuery.sap.each( model , function( index , item ) {
				item["SRTFT"]	=	false;
			});
			model[ Number( path ) ][ "SRTFT" ]	=	true;
		}
	},
	
	onEdit: function ( source ) {
		var model			=	this.getView().getModel( "Edit" ),
			OEdit 			= 	model.getProperty( "/EditOn" );
		model.setProperty( "/EditOn" , !OEdit );
		model.setProperty( "/buttonOn" , OEdit );
		if( this.pageName === "Detail" && this.getView().getModel( "ingredientTab" ).getData().length > 0 ){
			model.setProperty( "/EditStatus" , !OEdit );
		}else{
			model.setProperty( "/EditStatus" , false );
		}
		if( !OEdit ){
			var table	=	this.byId( "versionTable" ),
				path	=	table.getContextByIndex( table.getSelectedIndex() ).getPath().split( "/" )[1],
				version	=	this.getView().getModel( "versionTable" ).getData(),
				stats	=	this.getView().getModel( "articleData" ).getProperty( "/STATS" ),
				date	=	Number( this.toDateString( new Date() ) );
			this.setEditableIng( model, version, path, date, stats );
			if( this.editableIng ){
				model.setProperty( "/EditableIng", true );
				model.setProperty( "/deleteVersion" , "Delete" );
				this.byId( "removeVersion" ).setVisible( true );
			}else{
				model.setProperty( "/EditableIng", false );
				model.setProperty( "/deleteVersion" , "None" );
				this.byId( "removeVersion" ).setVisible( false );
			}
				model.setProperty( "/delete" , "Delete" );
		}else{
			model.setProperty( "/EditableIng", false );
			model.setProperty( "/delete" , "None" );
			model.setProperty( "/deleteVersion" , "None" );
			this.byId( "removeVersion" ).setVisible( false );
		}
		if( source !== "lock" ){
			this.onLockEdit("L", this.RCNUM, OEdit, model);
		}
	
		
		// if( !OEdit ){
		// 	if( this.onLockEdit("L", this.RCNUM, true) ){
		// 		model.setProperty( "/delete" 	, "Delete" );
		// 		if( this.getView().getModel( "articleData" ).getProperty( "/FRNUM" ) && 
		// 			this.getView().getModel( "articleData" ).getProperty( "/FRNUM" ).includes( "SR" ) ){
		// 			model.setProperty( "/deleteVersion", "Delete" );
		// 		}
		// 		if( !model.getProperty( "/Active") ){
		// 			this.byId( "removeVersion" ).setVisible( true );
		// 		}
		// 	}
		// }else{
		// 	if( this.onLockEdit("U", this.RCNUM, true) ){
		// 		model.setProperty( "/delete" 	, "None" );
		// 		// model.setProperty( "/EditableIng", false );
		// 		model.setProperty( "/deleteVersion", "None" );
		// 		this.byId( "removeVersion" ).setVisible( false );
		// 	}
		// }
	},
	
		
	setEditableIng: function( edit, model, path, date, stats ){
			if( path >= 0 && edit.getProperty( "/EditOn" ) && 
				(	Number( model[ path ].APDEB ) >  date || 
					(	
						Number( stats ) <= 12 &&
						Number( model[ path ].APDEB ) <=  date	&&	
						Number( model[ path ].APFIN ) >=  date 
					) || this.getView().getModel( "articleData" ).getData().ISFIC
				)){
				this.editableIng	=	true;
				edit.setProperty( "/EditableIng", true );
				edit.setProperty( "/deleteVersion", "Delete" );
				this.byId( "removeVersion" ).setVisible( true );
			}else{
				this.editableIng	=	false;
				edit.setProperty( "/EditableIng", false );
				edit.setProperty( "/deleteVersion", "None" );
				this.byId( "removeVersion" ).setVisible( false );
			}
		},
	
	onWarningPreview: function( oEvent ){
		if (! this._warningPopover) {
			this._warningPopover = sap.ui.xmlfragment("CatalogRecette.Fragment.warningPopover", this);
			this.getView().addDependent(this._warningPopover);
		}

		var oButton = oEvent.getSource();
		jQuery.sap.delayedCall(0, this, function () {
			this._warningPopover.openBy(oButton);
		});
	},
	
	addFilter: function (oEvent) {
		// create popover
		if (! this._filtersPopover) {
			this._filtersPopover = sap.ui.xmlfragment("CatalogRecette.Fragment.filtersPopOver", this);
			this.getView().addDependent(this._filtersPopover);
		}

		var oButton = oEvent.getSource();
		jQuery.sap.delayedCall(0, this, function () {
			this._filtersPopover.openBy(oButton);
		});
	},
	
	// onClearFilter: function(){
	// 	this.getView().getModel( "QuickFilter" ).setData({});
	// 	this.handleSearch();
	// },
	closeFilterPopover: function( event ){
		this._filtersPopover.close();
	},
	
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
									thisDetail.initCalculateModel();
									// thisDetail.navigationTo("Overview", "", false);
									thisDetail.onEdit();
									dialog.close();
									window.history.go( -1 );
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
								thisDetail.getView().setBusy( false );
							}
				});
				dialog.open();
				
		}else{
			var	filter	=	this.getOwnerComponent().getComponentData();
			if ( filter &&	filter.startupParameters.FRNUM && filter.startupParameters.FRNUM[0] ) {
				this.initCalculateModel();
				window.history.go( -1 );
			}else{
				this.initCalculateModel();
				this.getView().getParent().getParent().getParent().getModel( "DuplicateVersion" ).setData( {} );
				// this.navigationTo("Overview", "", false);	
				window.history.go( -1 );
			}
		}	
	},
	initCalculateModel: function(){
		this.getView().getModel( "calculateModel" ).setData({	"Commercial"	:	"ZLOG" ,
																		"distrib"	:	"10",
																		"Price"		:	"FR",
																		"Date"		:	this.toDateString( new Date() )});	
	},
	formatDate:function( date ){
		if( date.length < 2 ){
			date = "0" + date;
		}
		return date;
	},
	VersionPopover: function( event ){
		var fictif	=	this.getView().getModel( "articleData" ).getProperty( "/ISFIC" );
		if( fictif ){
			if (! this._VersionPopover) {
				this._VersionPopover = sap.ui.xmlfragment("CatalogRecette.Fragment.VersionPopover", this);
				this.getView().addDependent(this._VersionPopover);
			}
	
			var oButton = event.getSource();
			jQuery.sap.delayedCall(0, this, function () {
				this._VersionPopover.openBy(oButton);
			});
		}else{
			this.addVersion( false );
		}
	},
	closeVersionPopover: function(){
		this.getView().getModel( "helpModel" ).setProperty( "/DescriptionVersion", "" );
		this._VersionPopover.close();
	},
	
	addVersion:function( fictif ){
		var service		=	this.getView().getModel("CatRectService"),
			line		=	service.createEntry("/VersionSet").getObject(),
			help		=	this.getView().getModel( "helpModel" ),
			model		=	this.getView().getModel( "versionTable" ).getData(),
			ingredient	=	this.getView().getModel( "ingredientTab" ).getData(),
			ftver		=	null,
			date		=	new Date(),
			today		=	this.toDateString( date ),
			last		=	null,
			check		=	false;
		if( model.length === 0 ){
			ftver	= 1;
			last	= 0;
		}else{
			last	= model.length-1;
			ftver	= Number( model[ last ].FTVER );
			check	=	true;
		}
		delete line["_bCreate"];
		if( fictif ){
			line.DESCR		=	help.getProperty( "/DescriptionVersion" );
			help.setProperty( "/DescriptionVersion", "" );
		}
		if( check ){
			if( Number( model[ last ].APDEB ) > Number( today ) ){
				var temp	=	this.toDate( model[ last ].APDEB );
				temp.setDate(temp.getDate() + 1);
				model[ last ].APFIN = this.toDateString( temp );
				temp.setDate(temp.getDate() + 1);
				line.APDEB =	this.toDateString( temp );
			}
			else{
				model[ last ].APFIN = today;
				date.setDate(date.getDate() + 1);
				line.APDEB = this.toDateString( date );
			}
		}
		line.FTVER		=	ftver + 1 + "";
		line.APFIN		=	"99991231";
		line.NBGST		=	"0";
		line.TMPPR		=	{	__edmType	:	"Edm.Time",
								ms			:	0};
		model.push( line );
		this.getView().getModel( "versionTable" ).setData( model );
		for (var i=0; i<ingredient.length; i++) {
			if(	ingredient[i].FTVER ===	ftver + "" ){
				var temp	=	jQuery.extend({}, ingredient[i]);
				temp.FTVER	=	ftver + 1 + "";
				ingredient.push( temp );
			}
		}
		this.getView().getModel( "ingredientTab" ).setData( ingredient );
		this.byId( "versionTable" ).setSelectedIndex( model.length - 1 );
		if( fictif ){
			this.closeVersionPopover();
		}
		
	},
	
	removeVersion: function( event ){
		var table			=	this.byId( "versionTable" ),
			index			=	table.getSelectedIndex(),
			versionModel	=	this.getView().getModel( "versionTable" ).getData(),
			ingredientModel	=	this.getView().getModel( "ingredientTab" ).getData(),
			ingTemp			=	[],
			temp			=	[],
			i				=	0;
			
		if( versionModel[index]["SRTFT"] ){
			var oBundle		=	this.getView().getModel("i18n").getResourceBundle(),
					errorDialog	=	new sap.m.Dialog({
					title: oBundle.getText( "DELETE_VERSION" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "ERROR_DELETE_VERSION" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							errorDialog.close();
						}
					}),
					afterClose: function () {
						errorDialog.destroy();
					}
				});
				errorDialog.open();
				return;
		}
		
		if( index === 0 ){
			for ( i = 1 ; i < versionModel.length; i++) {
				temp.push( versionModel[i] );
			}
		}else if( index === versionModel.length - 1 ){
			for ( i = 0 ; i < versionModel.length - 1; i++) {
				if( i === versionModel.length - 2 ){
					versionModel[i].APFIN = "99991231";
				}
				temp.push( versionModel[i] );
			}
		}else{
			for ( i = 0 ; i < versionModel.length ; i++) {
				if( i + 1 === index ){
					var date = this.toDate( versionModel[i + 2 ].APDEB );
					versionModel[i].APFIN = this.toDateString( new Date( date.setDate(date.getDate() - 1) ) );
				}
				if( i !== index ){
					temp.push( versionModel[i] );
				}
			}		
		}
		for (var i=0; i<ingredientModel.length; i++) {
			if( versionModel[ index ].FTVER !== ingredientModel[i].FTVER ){
				ingTemp.push( ingredientModel[i] );
			}
		}
		this.getView().getModel( "ingredientTab" ).setData( ingTemp );
		this.getView().getModel( "versionTable" ).setData( temp );
		table.setSelectedIndex(-1);
		this.byId( "removeVersion" ).setVisible( false );
	},
	
	timeChange:function( event ){
		var value	=	event.getParameter( "value" ).split(":"),
			path	=	event.getSource().getId().split("row")[1],
			model	=	this.getView().getModel("versionTable").getData();
		
		
		model[path].TMPPR.ms = Number(value[0])*3600000 + Number(value[1])*60000 + Number(value[2])*1000;
		this.getView().getModel("versionTable").setData( model );
		
	},
	
	dateFormat: function( value ){
		var temp	=	value.split(".");
		return temp[2] + temp[1] + temp[0];
	},
	
	changeBeginDate:function( event ){
		var value = Number( this.dateFormat( event.getParameter( "value" ) ) ),
			date		=	new Date();
		date.setDate(date.getDate() );
		var	mounth		=	this.formatDate( date.getMonth() + 1 + "" ),
			day			=	this.formatDate( date.getUTCDate() + "" );
		date	=	date.getFullYear() + mounth + day;
		if(  value < Number( date ) ){
			event.getSource().setValue(date);
		}else{
			value		=	value + "";
			var path	=	event.getSource().getId().split("row")[1] - 1,
				model	=	this.getView().getModel("versionTable").getData(),
				dateVal	=	this.toDate(value);
			if( path >= 0 ){
				dateVal.setDate(dateVal.getDate() - 1);
				mounth		=	this.formatDate( dateVal.getMonth() + 1 + "" );
				day			=	this.formatDate( dateVal.getUTCDate() + "" );
				model[path].APFIN	= 	dateVal.getFullYear() + mounth + day;
			}
			this.getView().getModel("versionTable").setData( model );
			this.getView().getModel("versionTable").setProperty( "/" + ( path + 1 ) + "/APDEB", value );
		}
	},
	
	// changeEndDate:function( event ){
	// 	var value	=	Number( event.getParameter( "value" ) ),
	// 		path	=	event.getSource().getId().split("row")[1] - 1,
	// 		model	=	this.getView().getModel("versionTable").getData();
	// 		if( ! ){
				
	// 		}
	// },
	toDate:function( value ){
		return new Date( value.substring(0,4) + "-" + value.substring(4,6) + "-" + value.substring(6,8) );
	},
	
	toDateString:function( date ){
		var mounth		=	this.formatDate( date.getMonth() + 1 + "" ),
			day			=	this.formatDate( date.getUTCDate() + "" );
		return date.getFullYear() + mounth + day;	
	},
	
	selectStatus:function( event ){
		var source	=	event.getSource(),
			key		=	source.getSelectedKey(),
			isfic	=	this.getView().getModel( "articleData" ).getProperty( "/ISFIC" );
		if( key	===	"00" ){
			if( !isfic ){
				source.setSelectedKey( "10" );
			}else{
				source.setSelectedKey( "11" );
			}
		}
	},
		
	HandleFilePress: function( event ){
		if( !this._FilesUploadSourcing ){
			this._FilesUploadSourcing = sap.ui.xmlfragment( "CatalogRecette.Fragment.FileTabPopUp", this);
			this.getView().addDependent(this._FilesUploadSourcing);
		}
	 	this._FilesUploadSourcing.open();
	},
	onCloseFileSourcing: function( event ){
		this._FilesUploadSourcing.close();
	},
	
	addRecipe: function( event ){
		var source	=	event.getSource(),
			id		=	source.getId(),
			path	=	"AddIngredient";
		if( !id.includes("addIngredient") ){
			path	=	source.getBindingContext( "ingredientTab" ).getPath();
		}
			
		if( !this._newIngredient ){
			this._newIngredient = sap.ui.xmlfragment( "CatalogRecette.Fragment.IngredientList", this);
			this.getView().addDependent(this._newIngredient);
		}
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VHIngredientSet" );
		var isfic	=	this.getView().getModel( "articleData" ).getProperty( "/ISFIC" );
		var frnum	=	this.getView().getModel( "articleData" ).getProperty( "/FRNUM" );
		if( isfic ){
			isfic	=	"SR";
		}else{
			isfic	=	"FT";
		}
		
		var filters	=	[];
		filters.push( new sap.ui.model.Filter( "CNTXT" , sap.ui.model.FilterOperator.EQ , isfic ) );
		filters.push( new sap.ui.model.Filter( "FRNUM" , sap.ui.model.FilterOperator.EQ , frnum ) );
		
		this._newIngredient.setBusy( true );
		
		
		this._newIngredient.path = path;
		this._newIngredient.cntxt = isfic;
		this._newIngredient.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
	 	this._newIngredient.open();
	},
	confirmIngredient: function( event ){
		var path        =   event.getParameter("selectedContexts")[0].getPath().split( "/" )[1],
			ingModel	=	this.getView().getModel( "ingredientTab" ),
            modelTable  =   ingModel.getData(),
            // vhmodel		=	this.getView().getModel( "VHModel" ),
            data        =   this.getView().getModel("VHModel").getProperty( "/" + path ),
            service     =   this.getView().getModel( "CatRectService" ),
            line        =   service.createEntry("/IngredientSet").getObject();
            
        if( data.WARNI ){
        	var oBundle 	= 	this.getView().getModel("i18n").getResourceBundle(),
				dialog	= new sap.m.Dialog({
					title: oBundle.getText( "CLOSED_STATUS" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "CREATE_ARTICLE" ) }),
		
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
			return;	
        }
        
		delete line["_bCreate"];
		line.MATNR		=	data.MATNR;	
		line.MATAC		=	data.MATAC;	
		line.MATAX		=   data.MAKTX;
		line.UNITE  	=	data.MEINS;
		line.STATS		=	data.STATS;
		line.TSTAT		=	data.VSTAT;
		
		var	currentView		=	this.getView(),
			ftver			=	this.byId( "ingredientTable" ).getBindingInfo("items").binding.aFilters[0].oValue1;
		if( this._newIngredient.path === "AddIngredient" ){
			line.TYPEA		=	data.TYPEA;
			line.ISAFT		=	false;
			line.FTVER		=	ftver;
			line.BDATE  	=	"";
			line.EXLOT  	=	false;
			line.FRNUM  	=	"";
			line.PLTYP  	=	"";
			line.QTE_7  	=	"0.00";
			line.QTYRL  	=	"0.00";
			line.RLVAL  	=	"0.00";
			line.UNIVL  	=	"0.00";
			line.PERTE		=	"0.00";
			line.MAKTX		=	"";
			line.VKORG  	=	"";
			line.VTWEG  	=	"";
			modelTable.push( line );
			currentView.getModel( "ingredientTab" ).setData( modelTable );
		}else{
			ingModel.setProperty( this._newIngredient.path + "/MATNR",line.MATNR );
			ingModel.setProperty( this._newIngredient.path + "/MATAC",line.MATAC );
			ingModel.setProperty( this._newIngredient.path + "/MATAX",line.MATAX );
			ingModel.setProperty( this._newIngredient.path + "/UNITE",line.UNITE );
		}
		this.setWarningModel(ftver);
		
    // }
	},
	ingredientSearch:function( event ){
		var value	=	event.getParameter("value"),
			filters	=	[],
			frnum	=	this.getView().getModel( "articleData" ).getProperty( "/FRNUM" );
		
		filters.push( new sap.ui.model.Filter( "FRNUM" , sap.ui.model.FilterOperator.EQ , frnum ) );
		
		if( value.length > 2 ){
			value	=	value.toUpperCase();
			if( !isNaN( value.charAt( 2 ) ) && 
				( value.startsWith( "FT" ) || value.startsWith( "SR" ) || value.startsWith( "AF" ) || !isNaN( value ) ) &&
				value.length > 5 ){
				filters.push( new sap.ui.model.Filter( "MAKTX" , sap.ui.model.FilterOperator.StartsWith , value ) );
				filters.push( new sap.ui.model.Filter( "CNTXT" , sap.ui.model.FilterOperator.EQ , this._newIngredient.cntxt ) );
				this._newIngredient.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
			}else if( !value.startsWith( "FT" ) && !value.startsWith( "SR" ) && !value.startsWith( "AF" ) && isNaN( value ) ){
				filters.push( new sap.ui.model.Filter( "MAKTX" , sap.ui.model.FilterOperator.Contains , value ) );
				filters.push( new sap.ui.model.Filter( "CNTXT" , sap.ui.model.FilterOperator.EQ , this._newIngredient.cntxt ) );
				this._newIngredient.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
			}
		}
			
	},
	onTPVDelete: function( event ){
		var path	=	Number( event.getParameter( "listItem" ).getBindingContextPath().split("/")[1] ),
			model	=	this.getView().getModel( "tpvTab" );
		this.onLineDelete(model, path);
		
	},
	onImageDelete: function( event ){
		var path	=	Number( event.getParameter( "listItem" ).getBindingContextPath().split("/")[1] ),
			model	=	this.getView().getModel( "imageTable" );
		this.onLineDelete(model, path);
		
	},
	onRecipeDelete: function( event ){
		var path	=	Number( event.getParameter( "listItem" ).getBindingContextPath().split("/")[1] ),
			model	=	this.getView().getModel( "ingredientTab" );
		this.onLineDelete(model, path);
		
	},
	onLineDelete:function( model, path ){
		var temp	=	model.getData();
		temp.splice( path , 1 );
		model.setData( temp );	
	},
	
	SaleArticle: function( event ){
		var id			=	event.getParameter( "id" ),
			path		=	event.getSource().getParent().getBindingContextPath(),
			matac		=	this.getView().getModel( "ingredientTab" ).getProperty( path  + "/MATNR" ),
			filters		=	[],
			currentView	=	this.getView(),
			vhmodel		=	this.getView().getModel( "VHModel" ),
			model		=	this.getView().getModel( "ingredientTab" );

			
		filters.push( new sap.ui.model.Filter( "MATAC" , sap.ui.model.FilterOperator.EQ , matac ) );
		currentView.setBusy( true );
		vhmodel.read( "/VHIngredientsAchatSet", {
			filters: filters, 
			success: function ( oData ) {	
				currentView.getModel( "articleSale" ).setData( oData.results );
				model.setProperty( path + "/MATAC", oData.results[0].MATAC );
				model.setProperty( path + "/MATAX", oData.results[0].MAKTX );

				currentView.setBusy( false );
			},
			error: function ( error ) {
			 	currentView.setBusy( false );
			}
		});
		
		if (! this._SaleArticle) {
			this._SaleArticle = sap.ui.xmlfragment("CatalogRecette.Fragment.SaleList", this);
			this.getView().addDependent(this._SaleArticle);
		}

		var oButton = event.getSource();
		jQuery.sap.delayedCall(0, this, function () {
			this._SaleArticle.openBy(oButton);
		});	
		
		// if( !this._SaleArticle ){
		// 	this._SaleArticle = sap.ui.xmlfragment( "CatalogRecette.Fragment.SaleList", this);
		// 	this.getView().addDependent(this._SaleArticle);
		// }
		this._SaleArticle.path = path;
		// this._SaleArticle.open();
		
	},
	confirmArtS:function( event ){
		var items		=	event.getSource(),
			code		=	items.getNumber(),
			description	=	items.getTitle(),
			model		=	this.getView().getModel( "ingredientTab" ),
			path		=	this._SaleArticle.path;
		model.setProperty( path + "/MATAC", code );
		model.setProperty( path + "/MATAX", description );
		this._SaleArticle.close();
	},
	/**
	 * Search function of SaleList
	 */
	handleArtSSearch: function(oEvent) {
		var sValue		= oEvent.getParameter("value"),
			oBinding	= oEvent.getSource().getBinding("items");

		this.handleDialogSearch(sValue, "MAKTX", "MATAC", oBinding);
	},
	/**
	 * Search function of IngredientList
	 */
	handleIngredientSearch: function(oEvent) {
		var sValue		= oEvent.getParameter("value"),
			oBinding	= oEvent.getSource().getBinding("items");

		this.handleDialogSearch(sValue, "MAKTX", "MATNR", oBinding);
	},
	/**
	 * LiveChange dialog list
	 * for check if the have value
	 */
	// checkValue: function( event ){
	// 	this.setInputState( event.getSource() );
	// },

	handleDialogSearch: function(value, name, description, binding) {
		var NameFilter = new sap.ui.model.Filter(name, sap.ui.model.FilterOperator.Contains, value),
			CodeFilter = new sap.ui.model.Filter(description, sap.ui.model.FilterOperator.Contains, value),
			allFilter = new sap.ui.model.Filter([NameFilter, CodeFilter], false);
		binding.filter(allFilter);
	},
	handleImagePress:function ( event ){
		var source 	=	event.getSource(),
			URL 	=	source.getSrc(),
			path	=	source.getBindingInfo( "src" ).binding.getContext().getPath().split("/")[1],
			model	=	this.getView().getModel( "imageTable" ).getData();

		if( !this._previewImageDialog ){
			this._previewImageDialog = sap.ui.xmlfragment( "CatalogRecette.Fragment.imageDialog", this);
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
		if( this.pageName !== "Detail" ){
			var oBundle 	= 	this.getView().getModel("i18n").getResourceBundle(),
				FileDialog	= new sap.m.Dialog({
					title: oBundle.getText( "NEW_ALERTE" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "FILE_ALERTE" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							FileDialog.close();
						}
					}),
					afterClose: function () {
						FileDialog.destroy();
					}
				});
				FileDialog.open();
			return;	
		}

		// create popover
		if (! this._ImagePopover) {
			this._ImagePopover = sap.ui.xmlfragment("CatalogRecette.Fragment.ImageAddFilePopOver", this);
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
	
	AddTPVPopOver: function (oEvent) {
		// create popover
		if (! this._TPVPopover) {
			this._TPVPopover = sap.ui.xmlfragment("CatalogRecette.Fragment.AddTPVPopOver", this);
			this.getView().addDependent(this._TPVPopover);
		}

		var oButton = oEvent.getSource();
		jQuery.sap.delayedCall(0, this, function () {
			this._TPVPopover.openBy(oButton);
		});
		var date	=	new Date(),
			day		=	date.getUTCDate() + "",
			month	=	date.getMonth() + 1 + "";
		if( day.length === 1 ){
			day	=	"0" + day;
		}
		if( month.length === 1 ){
			month	=	"0" + month;
		}
		var tpvModel = this.getView().getModel( "AddTPV" ).getData();
		tpvModel.DATAB	=	 date.getUTCFullYear() + month  + day + "";
		tpvModel.DATBI	=	"29991231";
		this.getView().getModel( "AddTPV" ).setData( tpvModel );
	},
	
	handleAddTPV: function( event ){
		var model		=	this.getView().getModel( "AddTPV" ).getData(),
			elements	=	this._TPVPopover.getAggregation("_popup").getAggregation("content")[0].getAggregation("form").getAggregation("formContainers")[0].getAggregation("formElements");
		if( !model.MCRNR || !model.POSTY ){
			if( !model.MCRNR ){
				elements[0].getAggregation("fields")[0].setValueState( sap.ui.core.ValueState.Error );
			}
			if( !model.POSTY ){
				elements[1].getAggregation("fields")[0].getAggregation("items")[1].setVisible(true);
			}
		}else{
			var line	=	this.getView().getModel( "CatRectService" ).createEntry("/TpvSet").getObject(),
				tpvTab	=	this.getView().getModel( "tpvTab" ).getData();
			delete line["_bCreate"];
			line.MCRNR = model.MCRNR;
			line.POSTY = model.POSTY;
			if( !model.DATAB ){
				var fullDate	=	new Date(),
					month		=	fullDate.getMonth();
				if( month / 10 !== 1 ){
					month = "0" + month;
				}
				var date = fullDate.getUTCFullYear() +  month + fullDate.getDate() + "";
				line.DATAB = date;		
			}else{
				line.DATAB = model.DATAB;
			}
			if( !model.DATBI ){
				line.DATBI = "99991231";		
			}else{
				line.DATBI = model.DATBI;	
			}
			
			line.FRNUM = this.getView().getModel( "articleData" ).getData().FRNUM;
			tpvTab.push( line );
			this.getView().getModel( "tpvTab" ).setData( tpvTab );
			this.closeTPVPopover();
		}
	},
	
	onTPVState:function( event ){
		var source	=	event.getSource();
		if( source.getValue() === "" ){
			source.setValueState( sap.ui.core.ValueState.Error );
		}else{
			source.setValueState( sap.ui.core.ValueState.Default );
		}
	},
	
	closeTPVPopover: function(){
		var elements	=	this._TPVPopover.getAggregation("_popup").getAggregation("content")[0].getAggregation("form").getAggregation("formContainers")[0].getAggregation("formElements");
		elements[0].getAggregation("fields")[0].setValueState( sap.ui.core.ValueState.Default );
		elements[1].getAggregation("fields")[0].getAggregation("items")[1].setVisible(false);
		this.getView().getModel( "AddTPV" ).setData( {} );
		this._TPVPopover.close();
	},
	
	// fullScreen:function(){
	// 	if( this.byId( "SplitPage" ).getShowSecondaryContent() ){
	// 		this.byId( "SplitPage" ).setShowSecondaryContent( false );
	// 		this.byId( "fullScreenId" ).setIcon( "sap-icon://exit-full-screen" );
	// 		this.getView().getModel( "Edit" ).setProperty( "/FullScreen", true );
	// 	}
	// 	else{
	// 		this.byId( "SplitPage" ).setShowSecondaryContent( true );
	// 		this.byId( "fullScreenId" ).setIcon( "sap-icon://full-screen" );
	// 		this.getView().getModel( "Edit" ).setProperty( "/FullScreen", false );
	// 	}
	// },
	
	Calculate:function( event ){
		var currentView		=	this.getView(),	
			calculateModel	=	currentView.getModel( "calculateModel" ).getData(),
			articleData 	=	currentView.getModel( "articleData" ).getData(),
			versionModel 	=	currentView.getModel( "versionTable" ),
			totalModel		=	currentView.getModel( "totalValor" ).getData(),
			service 		=	currentView.getModel( "CatRectService" ),
			edit			=	currentView.getModel( "Edit" ),
			table			=	this.byId( "versionTable" ),
			index			=	table.getSelectedIndex(),
			path			=	table.getContextByIndex(index).getPath(),
			date,
			ftver,
			model			=	currentView.getModel( "ingredientTab" ),
			filters 		=	[],
			count			=	0;
		if( versionModel.getProperty( path + "/FRNUM" )  !== undefined ){
			if( !articleData.ISFIC ){
				if( !event ){
					// date	=	versionModel.getProperty( path + "/APDEB" );
					date		=	Number( calculateModel.Date );
					currentView.getModel( "calculateModel" ).setProperty( "/Date", date );
				}else{
					date		=	Number( calculateModel.Date );
					 for(var i=0; i<versionModel.getData().length; i++) {
						if( Number( versionModel.getData()[i].APDEB ) < date && Number( versionModel.getData()[i].APFIN ) > date ){
							table.setSelectedIndex(i);
							break;
						}
					} 
				}
			}
			index			=	table.getSelectedIndex();
			path			=	table.getContextByIndex(index).getPath();
			ftver			=	versionModel.getProperty( path + "/FTVER" );
			filters.push( new sap.ui.model.Filter( "VKORG" , sap.ui.model.FilterOperator.EQ , calculateModel.Commercial ) );
			filters.push( new sap.ui.model.Filter( "VTWEG" , sap.ui.model.FilterOperator.EQ , calculateModel.distrib ) );
			filters.push( new sap.ui.model.Filter( "PLTYP" , sap.ui.model.FilterOperator.EQ , calculateModel.Price ) );
			filters.push( new sap.ui.model.Filter( "BDATE" , sap.ui.model.FilterOperator.EQ , calculateModel.Date ) );
	
			var param	=	[];
	
			currentView.setBusy( true );
				service.read( "/RecetteSet(FTVER='" + ftver + "',FRNUM='" + articleData.FRNUM + "')/RC2IN", {
					filters: filters, 
					success: function ( oData ) {	
						for (var i = 0; i < model.getData().length ; i++) {
							if( model.getProperty( "/" + i + "/FTVER" )	===	ftver ){
								model.setProperty( "/" + i , oData.results[count] );
								count++;
							}
						}
						var check	=	false;
						for (var i = 0; i < totalModel.length; i++) {
							if( totalModel[i].FTVER === ftver){
								check	=	true;
								break;
							}
						}
						if( !check ){
							totalModel.push( oData.results[ count ] ); 	
							// currentView.byId( "totalLabel" ).setText( oData.results[ count ].MAKTX );
							// currentView.byId( "totalValue" ).setText( oData.results[ count ].RLVAL );
							edit.setProperty( "/TotalValo", oData.results[ count ].RLVAL );
						}
						currentView.setBusy( false );
					},
					error: function ( error ) {
					 	currentView.setBusy( false );
					}
				},param);
		}else{
			if( event ){
				var oBundle		=	currentView.getModel("i18n").getResourceBundle(),
					errorDialog	=	new sap.m.Dialog({
					title: oBundle.getText( "VALORISATION_VERSION" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "VALO_ERROR" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							errorDialog.close();
						}
					}),
					afterClose: function () {
						errorDialog.destroy();
					}
				});
				errorDialog.open();
				return;
			}
		}
	},
	exitFullScreen:function(){
		this.byId( "SplitPage" ).setShowSecondaryContent( true );
		this.byId( "expandableButton" ).setVisible( true );
		this.byId( "collapseButton" ).setVisible( false );
	},
	onCancel:function(){
		var model	=	this.getView().getModel( "articleData" ).getData();
		this.onEdit();
		if( this.pageName !== "Detail" ){
			this.navigationTo("Overview", "", false);
		}else{
			this.readModel( "(FTVER='" + model.FTVER + "',FRNUM='" + model.FRNUM + "')" );
		}
	},
		_buildFilters: function () {
		var filterData 	= this.getView().getModel( "QuickFilter" ).getData(),
			filters 	= [],
			multi		= null;
		if( !this._filtersPopover ){
			multi		=	[];
		}else{
			multi		=	this._filtersPopover.getAggregation("_popup").
								getAggregation("content")[0].getAggregation("form").
								getAggregation("formContainers")[0].getAggregation("formElements")[5].
								getAggregation("fields")[0].getTokens();
		}

		if( filterData.Carte ) {
			//	Filter on reference number
			filters.push( new sap.ui.model.Filter( "CTNUM" , sap.ui.model.FilterOperator.StartsWith , filterData.Carte ));
			
			
		}
		
		if( multi.length > 0 ) {
			//	Filter on reference number
			var multiFilter = [];
			for (var i=0; i<multi.length; i++) {
				multiFilter.push( new sap.ui.model.Filter( "MAKTX" , sap.ui.model.FilterOperator.EQ , multi[i].getKey() ) );
			}
			filters.push(	new sap.ui.model.Filter( multiFilter, true ) );	
			// this.byId( "customFilterButton" ).setType( "Reject" );
		
		}
		// else{
		// 	this.byId( "customFilterButton" ).setType( "Default" );
		// }

		if( filterData.Family ) {
			//	Filter on reference number
			filters.push(	new sap.ui.model.Filter( "FAMIL" , sap.ui.model.FilterOperator.Contains , filterData.Family ) );
			// CodeFilter 	=	new sap.ui.model.Filter( "MFRNR" , sap.ui.model.FilterOperator.StartsWith , filterData.Manufacturer );	
			// allFilter 	=	new sap.ui.model.Filter([NameFilter, CodeFilter], false);
			// filters.push( allFilter );
		}

		if( filterData.Designation ) {
		// 	//	Filter on reference number
			filters.push(	new sap.ui.model.Filter( "TITRE" , sap.ui.model.FilterOperator.Contains , filterData.Designation ) );	
		// 	// CodeFilter 	=	new sap.ui.model.Filter( "DISTT" , sap.ui.model.FilterOperator.StartsWith , filterData.Distributeur );	
		// 	// allFilter 	=	new sap.ui.model.Filter([NameFilter, CodeFilter], false);
		// 	// filters.push( allFilter );
		}

		// // if( filterData.MultIngredient ) {
		// // 	//	Filter on reference number
		// // 	filters.push( new sap.ui.model.Filter( "TEMPB" , sap.ui.model.FilterOperator.StartsWith , filterData.Temperature ) );	
		// // }

		if( filterData.Enseigne ) {
			//	Filter on reference number
			filters.push( 	new sap.ui.model.Filter( "ENSGN" , sap.ui.model.FilterOperator.StartsWith , filterData.Enseigne ) );	
			
		}

		if( filterData.Status ) {
			//	Filter on reference number
			filters.push( new sap.ui.model.Filter( "STATS" , sap.ui.model.FilterOperator.StartsWith , filterData.Status ) );	
		}
		
		if( filterData.Recette ) {
			//	Filter on reference number
			filters.push( new sap.ui.model.Filter( "FRNUM" , sap.ui.model.FilterOperator.StartsWith , filterData.Recette ) );	
		}
 	return filters;
	},
	// CheckEmpty:function( event ){
	// 	var source	=	event.getSource(),
	// 		value	=	source.getValue();
	// 	if( value === "" ){
	// 		source.setValueState( "Error" );
	// 	}else{
	// 		source.setValueState( "None" );
	// 	}
	// },

	// handleSearch: function(){
	// 	var binding 	=	null,
	// 		filters 	=	this._buildFilters();
			
	// 	binding = this.byId( "masterList" ).getBinding("items");
			
	// 		if( filters.length > 0 ){
	// 			binding.filter( new sap.ui.model.Filter( filters, true) );
	// 		}else{
	// 			binding.filter( null );
	// 		}
	// },
	
	restoreEnseigne: function( model ){
		var temp	=	[];
		jQuery.sap.each( model.items , function( index , item ) {
			jQuery.sap.each( item.items , function( ind , it ) {
				temp.push( it );
			});	
		});
		return temp;
	},
	
	/**
	 * Send to the server the new data of the article
	 */
	onModifRecetteCompleted: function( event ) {
		var currentView =	this.getView(),
			oBundle 	= 	currentView.getModel("i18n").getResourceBundle(),
			model		=	this.restoreEnseigne( currentView.getModel( "enseigneTable" ).getData() ),
			modelIng	=	currentView.getModel( "ingredientTab" ).getData(),
			flag		=	true;
		jQuery.sap.each( model , function( index , item ) {
			if( item.ACTIV ){
				flag	=	false;
				return;
			}
		});
		if( flag ){
			var enseigneDialog	= new sap.m.Dialog({
					title: oBundle.getText( "FIELD_EMPTY" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "ENSEIGNE_EMPTY" ) }),
		
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
		if( modelIng.length === 0 && this.recipeType.includes( "FT" ) ){
			var ingrediantDialog	= new sap.m.Dialog({
					title: oBundle.getText( "FIELD_EMPTY" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "INGREDIANT_EMPTY" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							ingrediantDialog.close();
						}
					}),
					afterClose: function () {
						ingrediantDialog.destroy();
					}
				});
				ingrediantDialog.open();
			return;
		}
		for (var i=0; i<modelIng.length; i++) {
			if( !modelIng[i].MATNR || !modelIng[i].MATAC || modelIng[i].MATNR === "" || modelIng[i].MATAC === "" ){
				var ArtDialog	= new sap.m.Dialog({
					title: oBundle.getText( "FIELD_EMPTY" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "ART_EMPTY" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							ArtDialog.close();
						}
					}),
					afterClose: function () {
						ArtDialog.destroy();
					}
				});
				ArtDialog.open();
			return;
			}
		}
		
		if( this.pageName !== "Detail" ){
			var modelG	=	this.getView().getModel( "articleData" ),
				nouvelC	=	this.getView().getModel( "NouvelleRecette" );
			flag	=	false;
			if( modelG.getProperty( "/TITRE" ) === "" ){
				nouvelC.setProperty( "/TITRE", "Error" );
				flag	=	true;
			}else{
				nouvelC.setProperty( "/TITRE", "None" );
			}
			if( modelG.getProperty( "/FAMIL" ) === ""  ){
				nouvelC.setProperty( "/FAMIL", true );
				flag	=	true;
			}else{
				nouvelC.setProperty( "/FAMIL", false );
			}
			if( flag ){
				var emptyDialog		= new sap.m.Dialog({
					title: oBundle.getText( "FIELD_EMPTY" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "EMPTY" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							emptyDialog.close();
						}
					}),
					afterClose: function () {
						emptyDialog.destroy();
					}
				});
				emptyDialog.open();
				return;
			}
			currentView.getModel( "articleData" ).setProperty( "/FRNUM", "$" );
		}
		var thisDetail				=	this,
			rctService 				= currentView.getModel( "CatRectService" ),
			rctHeadr				= currentView.getModel( "articleData" ).getData(),
			rctEnseigne				= this.restoreEnseigne( currentView.getModel( "enseigneTable" ).getData() ),
			rctVolume				= currentView.getModel( "volumeTab" ).getData(),
			rctIngredient			= currentView.getModel( "ingredientTab" ).getData(),
			rctVersion				= currentView.getModel( "versionTable" ).getData(),
			rctText		 			= currentView.getModel( "texteTab" ).getData(),
			rctTPV		 			= currentView.getModel( "tpvTab" ).getData(),
			rctImage		 		= currentView.getModel( "imageTable" ).getData(),
			rctFile					= currentView.getModel( "articleFileTable" ).getData(),
			rctHistory				= currentView.getModel( "journalTable" ).getData(),
			rctToModif 				= {},
			oMsgStrip				= null,
			msgArea 				= this.getView().byId( "msgArea" );
			msgArea.removeAllItems();
			
		for (i=0; i<rctImage.length; i++) {
			if( rctImage[i].DESCR === "" ){
				var FileDialog	= new sap.m.Dialog({
					title: oBundle.getText( "FIELD_EMPTY" ),
					type: 'Message',
					content: new sap.m.Text({ text: oBundle.getText( "DESC_EMPTY" ) }),
		
					endButton: new sap.m.Button({
						icon : "sap-icon://decline",
						type: "Reject",
						press: function () {
							FileDialog.close();
						}
					}),
					afterClose: function () {
						FileDialog.destroy();
					}
				});
				FileDialog.open();
			return;
			}
		}

		rctHeadr.PRIXI	=		rctHeadr.PRIXI + "";
		rctHeadr.BRGEW	=		rctHeadr.BRGEW + "";
		for (i=0; i<rctVersion.length; i++) {
			rctVersion[i].NBGST	=	Number( rctVersion[i].NBGST );
		}
		
		rctText[0].PREPAR	=	this.goNextLine( rctText[0].PREPAR );	
		rctText[0].MODOP	=	this.goNextLine( rctText[0].MODOP );	
		rctText[0].MATERL	=	this.goNextLine( rctText[0].MATERL );	
		rctText[0].PTCRQ	=	this.goNextLine( rctText[0].PTCRQ );	
		
		
		//	Prepare object for server call
		rctToModif 				= rctHeadr; 
		rctToModif.RC2EN		= rctEnseigne;
		rctToModif.RC2VL		= rctVolume;
		rctToModif.RC2IN		= rctIngredient;
		rctToModif.RC2VR		= rctVersion;
		rctToModif.RC2TX		= rctText;
		rctToModif.RC2TP		= rctTPV;
		rctToModif.RC2IM		= rctImage;
		rctToModif.RC2SF		= rctFile;
		rctToModif.RC2HS		= rctHistory;
		rctToModif.RC2ST		= thisDetail.getView().getModel( "StatList" ).getData();
		
		
		// if( this.pageName == "NewArticleCopy"){
		// 	rctToModif = thisDetail.onSaveCopy( rctToModif );
		// }

		//	Delete metadata
		delete rctToModif.__metadata;

		jQuery.each( rctToModif , function( index , field ) {
			if( jQuery.isArray( field )) {
				jQuery.each( field , function( indexj , item ) {
					delete item.__metadata;
				});
			}
		});

		this.dataChanged 	= true;

		//	Set busy indicator
		currentView.setBusy( true );				

		//	Call server
		rctService.create( "/RecetteSet" , rctToModif , {
			success: function( data, response ) {
				//	Disable busy indicator
				currentView.setBusy( false );				

				// if( response ){
				// 	//	Display message
				// 	var message 	=	JSON.parse(response.headers["sap-message"]);
				// 	sap.m.MessageToast.show( message.message , {duration: 3000});
				
				// }
			thisDetail.onEdit();
			if( thisDetail.pageName === "Detail" ){
				thisDetail.readModel( "(FTVER='" + data.FTVER +"',FRNUM='" + data.FRNUM + "')" );
			}else{
				thisDetail.navigationTo("Detail", {"Recette"	:	"(FTVER='" + data.FTVER +"',FRNUM='" + data.FRNUM + "')"}, false);
			}
				
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
	},
	GeneralInfoAddFilePopOver: function (oEvent) {

		// create popover
		if (! this._gInfoPopover) {
			this._gInfoPopover = sap.ui.xmlfragment("CatalogRecette.Fragment.GeneralInfoaddFilePopOver", this);
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
	
	onFileDelete:function( event ){
		var path	=	Number( event.getParameter( "listItem" ).getBindingContextPath().split("/")[1] ),
			model	=	this.getView().getModel( "articleFileTable" );
		this.onLineDelete(model, path);
	},

	GeneralUploadFile: function ( event ){
		var model			=	this.getView().getModel( "articleData" ),
			imgModel		=	this.getView().getModel( "UploadImage" ),
			fileUploader	=	event.getSource().getParent().getParent().getParent().getContent()[0].getItems()[1].getItems()[0],
			objnr			=	model.getProperty( "/FRNUM" ),
			objtp			=	"R",
			fname			=	imgModel.getProperty( "/URL" ),
			mfrnr			=	"",
			descr			=	imgModel.getProperty( "/description" );
		if( this.pageName !== "Detail" ){
			
		}
		if( objnr.includes( "FT" ) ){
			objtp	=	"F";
		}else{
			objtp	=	"S";
		}
		if( descr && descr !==	"" && fname && fname !==	"" ){
			
			imgModel.setProperty( "/descriptionSate", "None" );
			if( fileUploader.getId() === "generalInfoUploader" ){
				objtp			=	"R";
			}
			this.uploadPress( fileUploader, objnr, objtp, fname, mfrnr, descr );
			if( fileUploader.getId() === "generalInfoUploader" ){
				this.closegInfoPopover();
			}else{
				this.closegImagePopover();
			}
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
	},
	/**
	 * On Type not allowed
	 * @param  {jQuery.Event} oEvent 
	 */
	uploadPress: function( oFileUploader,  objnr, objtp, fname, mfrnr, descr ) {
		var oDataModel 		= this.getView().getModel( "FileUpload" ),
			oBundle 		= this.getView().getModel( "i18n" ).getResourceBundle();
		
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
			oBundle 	=	this.getView().getModel( "i18n" ).getResourceBundle(),
			vArtNum		=	oView.getModel( "articleData" ).getProperty("/FRNUM"),
			modelTab	=	this.getView().getModel( "imageTable" ),
			raw			=	oEvent.getParameter("responseRaw"),
			xmlDoc		=	jQuery.parseXML( raw ),
			uploadMsg	=	null,
			entitySet	=	"/ImageSet",
			field,
			id			=	oEvent.getParameter( "id" );
			switch ( id ) {
				case "generalInfoUploader":
					modelTab	=	this.getView().getModel( "articleFileTable" );
					entitySet	=	"/SrcFileSet";
					field		=	"OBJNR";
					this.closegInfoPopover();
					break;
				case "FilesUploader":
					modelTab	=	this.getView().getModel( "imageTable" );
					entitySet	=	"/ImageSet";
					field		=	"FRNUM";
					this.closegImagePopover();
					break;
			}
			
	
		//	Build Filter for Article Number
		
			var filter 		= new sap.ui.model.Filter({ 
				path 	: 	field,
				operator: 	sap.ui.model.FilterOperator.EQ,  
				value1 	: 	vArtNum
			});
		

		if ( vStatus === 201 || vStatus === 200 ) {
			oView.getModel( "CatRectService" ).read( entitySet, {
				filters: [ filter ],
				success: function( oData ) {
					//	Free the View
					oView.setBusy( false );

					//	Update Image Table Model
					modelTab.setData( oData.results );

					//	Success Message
					sap.m.MessageToast.show( oBundle.getText( "UPLOAD_SUCCESS" ) );
				},
				error: function( oError ) {
					//	Free the View
					sap.m.MessageToast.show( JSON.parse(oError.responseText).error.message.value );
					oView.setBusy( false );

				}
			});
		} else {
			uploadMsg	=	xmlDoc.getElementsByTagName("message")[0].childNodes[0].nodeValue;
			//	Free the View
			oView.setBusy( false );

			//	Success Message
			sap.m.MessageToast.show( uploadMsg );
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
	onMainImageSelect: function( event ){
		var value	=	event.getParameter( "selected" );
		if( value ){
			var model	=	this.getView().getModel( "articleData" ),
				imgModel=	this.getView().getModel( "imageTable" ),
				path	=	event.getSource().getParent().getBindingContext("imageTable").getPath();
			model.setProperty( "/IMSRC", imgModel.getProperty( path + "/IMSRC" ) );
		}else{
			return;
		}
	},
	handleVolumeSearch: function( event ){
		var filter	=	this.getView().getModel( "volumeFilter" ).getData(),
			table	=	this.byId( "volumeTable" ),
			binding	=	table.getBinding( "items" ),
			filters	=	[],
			rangeFilter	=	[],
			debFilter	=	[],
			finFilter	=	[];
			if( filter.CTNUM ){
				filters.push(	new sap.ui.model.Filter( "CTNUM" , sap.ui.model.FilterOperator.EQ , filter.CTNUM ) );
			}
			if( filter.APDEB ){
				var deb			=	filter.APDEB.split( " - " )[0],
					fin 		=	filter.APDEB.split( " - " )[1],
					dateFilter	=	[],
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
				rangeFilter.push(	new sap.ui.model.Filter( debFilter,true) );
				rangeFilter.push(	new sap.ui.model.Filter( finFilter,true) );
				rangeFilter.push(	new sap.ui.model.Filter( dateFilter,true) );
				filters.push(	new sap.ui.model.Filter(rangeFilter,false) );
			
				filters.push( new sap.ui.model.Filter(dateFilter,false) );
				// filters.push(	new sap.ui.model.Filter( "APDEB" , sap.ui.model.FilterOperator.EQ , filter.APDEB ) );
			}
			// if( filter.APFIN ){
			// 	filters.push(	new sap.ui.model.Filter( "APFIN" , sap.ui.model.FilterOperator.EQ , filter.APFIN ) );
			// }
			if( filters.length > 0 ){
				binding.filter( new sap.ui.model.Filter( filters, true ) );
			}else{
				binding.filter( null );
			}
			var totalModel	=	this.getView().getModel( "total" ),
				tableModel	=	this.getView().getModel( "volumeTab" ),
				line		,
				totalP		=	0,
				totalM		=	0,
				path		,
				items		=	table.getItems();
			for (var i = 0 ; i < items.length ; i++ ){
				path	=	items[i].getBindingContext( "volumeTab" ).getPath();
				line	=	tableModel.getProperty( path );
				totalP	=	Number( totalP ) + Number( line.VLPER );
				totalM	=	Number( totalM ) + Number( line.VLMEN );
			}
			totalModel.setData( {	
									"totalP" : totalP,
									"totalM" : totalM });
	},
	onClearFilterVolume: function( event ){
		this.getView().getModel( "volumeFilter" ).setData( {} );
		this.handleVolumeSearch( event );
	},
	addCarte: function( event ){
		if( !this._CarteList ){
			this._CarteList = sap.ui.xmlfragment( "CatalogRecette.Fragment.CarteList", this);
			this.getView().addDependent(this._CarteList);
		}
	 	this._CarteList.open();
	},
	handleCarteSearch:function( event ){
		var value	=	event.getParameter("value"),
			filters	=	[];
		filters.push( new sap.ui.model.Filter( "CTNUM" , sap.ui.model.FilterOperator.Contains , value ) );
		filters.push( new sap.ui.model.Filter( "DESCR" , sap.ui.model.FilterOperator.Contains , value ) );
		this._CarteList.getBinding("items").filter( new sap.ui.model.Filter( filters, true) );
	},
	closeCarteList: function( event ){
		this._CarteList.getBinding("items").filter( new sap.ui.model.Filter( "CTNUM" , sap.ui.model.FilterOperator.NE , "" ) );
		// this._CarteList.close();
	},
	onCarteDelete: function( event ){
		var path	=	event.getParameter( "listItem" ).getBindingContext( "volumeTab" ).getPath().split("/")[1],
			model	=	this.getView().getModel( "volumeTab" ).getData(),
			temp	=	[];
		 for(var i=0; i<model.length; i++) {
			if( i !==	Number( path ) ){
				temp.push( model[i] );
			}
		}
		this.getView().getModel( "volumeTab" ).setData( temp );
	},
	confirmCarte: function( event ){
		var path        =   event.getParameter("selectedContexts")[0].getPath().split( "/" )[1],
			volModel	=	this.getView().getModel( "volumeTab" ),
            modelTable  =   volModel.getData(),
            data        =   this.getView().getModel("VHModel").getProperty( "/" + path ),
            service     =   this.getView().getModel( "CatRectService" ),
			currentView	=	this.getView(),
            line        =   service.createEntry("/VolumeSet").getObject();
        
		delete line["_bCreate"];
		line.CTNUM		=	data.CTNUM;	
		line.DESCR		=	data.DESCR;	
		line.FRNUM		=   this.RCNUM;
		
		modelTable.push( line );
		currentView.getModel( "volumeTab" ).setData( modelTable );
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
	onOpenPdf: function( event ) {
		var calculate		=	this.getView().getModel( "calculateModel" ).getData(),
			versionModel	=	this.getView().getModel( "versionTable" ),
			data			=	this.getView().getModel( "articleData" ).getData(),
			frnum			=	data.FRNUM,
			table			=	this.byId( "versionTable" ),
			path   			=	table.getContextByIndex( table.getSelectedIndex() ),
			ftver			=	versionModel.getProperty( path + "/FTVER" ),
			oView			=	this.getView(),
			oHtml 			=	new sap.ui.core.HTML(),
			oBundle 		= 	this.getView().getModel("i18n").getResourceBundle(),
			model			=	this.getView().getModel( "enseigneTable" ).getData(),
			ensgn			=	[],
			sPdfURL			=	"/sap/opu/odata/sap/ZFT_GW_CAT_RECETTE_SRV/ImpressionFicheSet(FRNUM='" + frnum + "',FTVER='" + ftver + "',PLTYP='" + calculate.Price + "',VKORG='" + calculate.Commercial + "',VTWEG='" + calculate.distrib + "',BDATE='" + calculate.Date +  "'",
			sHtmlContent;
		for (var i=0; i<model.items.length; i++) {
			for (var j = 0; j < model.items[i].items.length; j ++) {
				if( model.items[i].items[j].ACTIV ){
					ensgn.push( model.items[i].items[j].ENSGN );
				}
			}              
		}
		if( ensgn.length === 1 ){
			sPdfURL 			=	sPdfURL + ",ENSGN='" + ensgn[0] + "')/$value";
		}else{
			sPdfURL 			=	sPdfURL + ",ENSGN='')/$value";
		}
		if( !calculate.Commercial || !calculate.distrib ||
			!calculate.Price || !calculate.Date ||
			calculate.Commercial === "" || calculate.distrib === "" ||
			calculate.Price === "" || calculate.Date === "" ){
			sap.m.MessageBox.alert( oBundle.getText( "ERROR_PRINT" ) );
		}else{
			// Create Dialog
			var oDialog 		= new sap.m.Dialog({
				title: 		"PDF",
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
		}
		
	}
	
});