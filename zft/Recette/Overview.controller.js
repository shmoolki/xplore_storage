jQuery.sap.require( "sap/ui/model/Filter" );
jQuery.sap.require( "sap/ui/model/FilterOperator" );
jQuery.sap.require(	"CatalogRecette/util/Formatter" );
sap.ui.controller(  "CatalogRecette.controller.Overview", {
	/**
	* Called when a controller is instantiated and its View controls (if available) are already created.
	* Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
	* @memberOf test.detail
	*/
	flag	:	false,
	thisOverview: null,
	Formatter : CatalogRecette.util.Formatter,
	onInit: function() {
		this.getView().addStyleClass( "sapUiSizeCompact" );
		thisOverview = this;
		//	Routing
		this.router 	= sap.ui.core.UIComponent.getRouterFor(this);
		this.router.attachRoutePatternMatched( this.handleRouting , this);
		this._BusyDialog = sap.ui.xmlfragment(
			"CatalogRecette.Fragment.BusyDialog",
			this
		);
		this.getView().addDependent(this._BusyDialog);
		
			this.byId("multiIngredients").setFilterFunction(function(sTerm, oItem) {
			var check	=	false;
			sTerm	=	sTerm.toUpperCase();
			if( ( sTerm.startsWith( "AF" ) || sTerm.startsWith( "SR" ) || sTerm.startsWith( "FT" ) || !isNaN( sTerm ) ) ){
				if( sTerm.length > 5 ){
					check	=	true;	
				}
			}else if( sTerm.length > 2 ){
				check		=	true;
			}
			if( check ){
				// A case-insensitive 'string contains' style filter
				return oItem.getText().match(new RegExp(sTerm, "i"));
			}
		});
		this.byId("opeGammeId").setFilterFunction(function(sTerm, oItem) {
			var check	=	false;
			sTerm	=	sTerm.toUpperCase();
			if( sTerm.startsWith( "CR" ) ){
				if( sTerm.length > 5 ){
					check	=	true;	
				}
			}else if( sTerm.length > 2 ){
				check		=	true;
			}
			if( check ){
				// A case-insensitive 'string contains' style filter
				return oItem.getText().match(new RegExp(sTerm, "i"));
			}
		});
		
		this.InitModels();
	},
	/**
	 * Models initialization
	 */
	InitModels: function(){

		// Article Data model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "recetteTable" );
		
			// Article Data model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "articleTable" );
		// this.getView().getModel( "articleTable" ).setSizeLimit( 100000 );
		
			// Article Data model
		this.getView().setModel( new sap.ui.model.json.JSONModel( { "FRNUM"	:	"",
																	"TITRE"	:	"",
																	"APDEB"	:	"",
																	"SRNUM"	:	""} ), "Duplicate" );

		// Filter model
		this.getView().setModel( new sap.ui.model.json.JSONModel( {	Recette : "",
																	SR_FT	: false,
																	Designation : ""}), "QuickFilter" );
		
		this.getView().setModel( new sap.ui.model.json.JSONModel({	"Version" 		:	false
																	}), "Overview" );
																	
		var	filter	=	this.getOwnerComponent().getComponentData();
		if( filter ){
			if( filter.startupParameters.INGRD ){
				this.paramFilter	=	filter.startupParameters.INGRD[0].split( "'" )[1];		
			}
			if ( 	filter.startupParameters.FRNUM && filter.startupParameters.FRNUM[0] ) {
				var ftver	=	filter.startupParameters.FTVER[0],
					frnum	=	filter.startupParameters.FRNUM[0];
				
				// var newUrl	=	this.removeParam("FRNUM", document.URL);
				// window.history.replaceState({}, document.title, newUrl );
				this.navigationTo("Detail", { "Recette": "(FTVER='" + ftver + "',FRNUM='" + frnum + "')"}, true ) ;
				// filter.startupParameters.FRNUM = false;
				return;
			}
		}
		this.VHModelsInit();

	},
	handleRouting: function( event ){
		if( event.getParameter( "name" ) ){
			this.handleSearch();
		}
	},
	
	removeParam: function(key, sourceURL) {
	    var rtn = sourceURL.split("?")[0],
	        param,
	        params_arr = [],
	        queryString = (sourceURL.indexOf("?") !== -1) ? sourceURL.split("?")[1] : "";
	    if (queryString !== "") {
	        params_arr = queryString.split("&");
	        for (var i = params_arr.length - 1; i >= 0; i -= 1) {
	            param = params_arr[i].split("=")[0];
	            if (param === key) {
	                params_arr.splice(i, 1);
	            }
	        }
	        rtn = rtn + "?" + params_arr.join("&");
	    }
	    return rtn;
	},
		
	VHModelsInit: function(){
		var service 		= 	this.getOwnerComponent().getModel( "VHModel" ),
			that 			=	this,
			serverDone		=	[false,false,false];
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VHRecFamillesSet" );
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VHEnseignesSet" );
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VHStatutsSet" );
		
		
		service.read( "/VHRecFamillesSet",{    
			success: function( oData ) {
		        that.getView().getModel( "VHRecFamillesSet" ).setData( oData.results );
		        that.selectAll(false, "FamilyList",true);
		        serverDone[0] = true;
				that.callSearchServer( serverDone );
		    },
		    error: function( error ) {
		    }
    	});
    	
    
		service.read( "/VHEnseignesSet",{    
			success: function( oData ) {
		        that.getView().getModel( "VHEnseignesSet" ).setData( oData.results );
				that.selectAll(false, "EnseigneList",true);
				serverDone[1] = true;
				that.callSearchServer( serverDone );
		    },
		    error: function( error ) {
		    }
    	});
    	
		service.read( "/VHStatutsSet",{    
			success: function( oData ) {
		        that.getView().getModel( "VHStatutsSet" ).setData( oData.results );
		        var field		=	that.getView().byId( "StatusList" ),
					list		=	field.getItems(),
					items		=	[];
		        
				jQuery.each( list , function( key, value ) {
					if( value.getKey() !== "42" && value.getKey() !== "32" 
						&& value.getKey() !== "40" && value.getKey() !== "30" 
						&& value.getKey() !== "25" ){
						items.push( value.getKey() );
					}
				});
				field.setSelectedKeys( items );
				that.checkAllSelected( false, "StatusList" );
		        serverDone[2] = true;
				that.callSearchServer( serverDone );
		    },
		    error: function( error ) {
		    }
    	});
    	// Model du nombre de ligne de la table principal en fonction de la taille de l'ecran
		this.getView().setModel( new sap.ui.model.json.JSONModel({
																	Screen		:	13
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
		if( screenR <= 680 ){
			edit.setProperty( "/Screen" , 9 );
		}else if( screenR >	680	&& screenR	<	750 ){
			edit.setProperty( "/Screen" , 10 );
		}else if( screenR >	750	&& screenR	<	800 ){
			edit.setProperty( "/Screen" , 11 );
		}else if( screenR >	800	&& screenR	<	850 ){
			edit.setProperty( "/Screen" , 12 );
		}else if( screenR >	850	&& screenR	<	900 ){
			edit.setProperty( "/Screen" , 13 );
		}else{
			edit.setProperty( "/Screen" , 14 );
		}	
	},
	
	callSearchServer: function( serverDone ){
		if( !serverDone.includes( false ) ){
			this.handleSearch();
		}
	},
	
	removeFilter: function( event ){
		var id = event.getSource().getId().split("-");
		this.getView().getModel("QuickFilter").setProperty( "/" + id[ id.length - 1 ] , "" );
		this.checkAllSelected( event );
		this.handleSearch();
	},
	
	onVersionClick: function( event ){
		var key 			=	event.getSource().getSelectedKey(),
			filterModel 	=	this.getView().getModel("QuickFilter").getData();

		if( key === "true" && filterModel.length > 2 ){
			this.loadByVersion();
         }
         this.handleSearch();
	},
	
	loadByVersion: function() {
		var service 		=	this.getView().getModel( "CatRectService" ),
			thisOverview	=	this,
			filters			=	this._buildFilters()[0];

		this.getView().setBusy( true );
		
		filters.push( new sap.ui.model.Filter({
				path:		"VERSN",
				operator:	sap.ui.model.FilterOperator.EQ,
				value1:		true
			}));
		
		service.read( "/RecetteSet" , {
			filters: [new sap.ui.model.Filter( filters, true)],
			success: function ( oData ) {	
				thisOverview.getView().getModel( "articleTable" ).setSizeLimit(oData.results.length);                           
				thisOverview.getView().getModel( "articleTable" ).setData( thisOverview.treeModel( oData.results ) );
				thisOverview.getView().setBusy( false );
			},
			error: function ( error ) {
			 	thisOverview.getView().setBusy( false );
			}
		});
		
	},
	selectAll: function( event, fieldId, init ){
		var id,
			fieldName	=	"";
		if( event ){
			 id			=	event.getSource().getId();
		}else{
			id			=	fieldId;
		}
		if( id.includes( "Family" ) ){
			fieldName	=	"FamilyList";
		}
		if( id.includes( "Enseigne" ) ){
			fieldName	=	"EnseigneList";
		}
		if( id.includes( "Status" ) ){
			fieldName	=	"StatusList";
		}
		var field		=	this.getView().byId( fieldName ),
			list		=	field.getItems(),
			items		=	[];
			
		jQuery.each( list , function( key, value ) {
			items.push( value.getKey() );
		});
		field.setSelectedKeys( items );
		this.checkAllSelected( false, id);
		if( !init ){
			this.handleSearch();
		}
	},
	
	includeSrFt: function( event ){
		var multiId		=	this.byId( "multiIngredients" ).getBinding( "suggestionItems" ),
			filterModel	=	this.getView().getModel( "QuickFilter" ),
			include		=	filterModel.getProperty("/SR_FT");
		if( include ){
			multiId.filter( new sap.ui.model.Filter( "SR_FT" , sap.ui.model.FilterOperator.EQ ,include ) );
		}else{
			multiId.filter( null );
		}
	},
	
	checkAllSelected: function( event, fieldN ){
		var id,
			fieldName	=	"",
			iconId;
		if( !event ){
			id			=	fieldN;
		}else{
			id			=	event.getSource().getId();
		}
		
		if( id.includes( "Family" ) ){
			fieldName	=	"FamilyList";
			iconId		=	"FamilyLi";
		}
		if( id.includes( "Enseigne" ) ){
			fieldName	=	"EnseigneList";
			iconId		=	"EnseigneLi";
		}
		if( id.includes( "Status" ) ){
			fieldName	=	"StatusList";
			iconId		=	"StatusLi";
		}
		var field		=	this.getView().byId( fieldName ),
			list		=	field.getItems();
		if( list.length === field.getSelectedKeys().length ){
			this.byId( iconId ).setVisible( false );
		}else{
			this.byId( iconId ).setVisible( true );
		}
	},
	
	onClearFilter: function(){
		if( this.getView().getModel( "Overview" ).getData().Version === "true" ){
			var service		= this.getView().getModel( "CatRectService" ),
				thisOverview	= this;
			service.read( "/RecetteSet()"  , {
				async			:	false,
	         	success			:	function( oData ) {
	         		thisOverview.getView().getModel( "articleTable" ).setData( thisOverview.treeModel( oData.results ) );
	         	},
	         	error			:	function(){
	         		
	         	}
	         });
		}
		this.getView().getModel( "QuickFilter" ).setData({
															Recette : "",
															Designation : ""
		});
		this.byId( "multiIngredients" ).setTokens("");
		this.byId( "FamilyLi" ).setVisible( true );
		this.byId( "EnseigneLi" ).setVisible( true );
		this.byId( "StatusLi" ).setVisible( true );
		this.handleSearch();
	},
	DuplicateActionSheet : function (oEvent) {
		var oButton 		=	oEvent.getSource(),
			currentView		=	this.getView(),
			version			=	currentView.getModel( "Overview" ).getProperty( "/Version" ),
			duplicateModel	=	currentView.getModel( "Duplicate" ),
			model			=	null,
			modelPath		=	null,
			table			=	null,
			path			=	null,
			isfic			=	null,
			nbIng			=	null,
			cnfic			=	null,
			row				=	null;

		// create action sheet only once
		if (!this._actionSheet) {
			this._actionSheet = sap.ui.xmlfragment(
				"CatalogRecette.Fragment.DuplicateActionSheet",
				this
			);
			this.getView().addDependent(this._actionSheet);
		}
	
		this._actionSheet.openBy(oButton);
		if( oButton.getId().includes("New") ){
			this._actionSheet.setTitle("Nouvelle recette");
		}else{
			this._actionSheet.setTitle("Duplication de recette");
			if( version ){
				table		=	this.byId("Table");
				model		=	this.getView().getModel( "articleTable" );
			}else{
				table		=	this.byId("GTable");
				model		=	this.getView().getModel( "CatRectService" );
			}
			path		=	table.getSelectedIndex();
			modelPath	=	table.getContextByIndex( path ).getPath();
			row			=	model.getProperty( modelPath );
			isfic		=	row.ISFIC;
			cnfic		=	row.CNFIC;
			nbIng		=	row.NBING;                         
			duplicateModel.setProperty( "/SRNUM", row.FRNUM );
			if( isfic ){
				if( cnfic || nbIng === 0 ){
					this._actionSheet.getAggregation("buttons")[0].setVisible( false );
				}else{
					this._actionSheet.getAggregation("buttons")[0].setVisible( true );
				}
			}else{
				this._actionSheet.getAggregation("buttons")[0].setVisible( true );
			}
		}
	},
	
	DuplicateToVersion : function (oEvent) {
		var duplicateM	=	this.getView().getModel( "Duplicate" ),
			date		=	new Date();
		date.setDate( date.getDate() + 1 );
		date	=	this.toDateString( date );

		// create action sheet only once
		if (!this._DuplicatePopOver) {
			this._DuplicatePopOver = sap.ui.xmlfragment(
				"CatalogRecette.Fragment.SRversionFTPopOver",
				this
			);
			this.getView().addDependent(this._DuplicatePopOver);
		}

		this._DuplicatePopOver.open();
		duplicateM.setProperty( "/APDEB" , date );
	},
	closeSrToFt: function(){
		var model	=	this.getView().getModel( "Duplicate" );
		model.setProperty( "/FRNUM", "" );
		model.setProperty( "/TITRE", "" );
		model.setProperty( "/APDEB", "" );
		this._DuplicatePopOver.close();
	},
	newVersion: function(){
		var duplicateModel	=	this.getView().getModel( "Duplicate" ),
			service			=	this.getView().getModel( "CatRectService" ),
			flag			=	false,
			version			=	null,
			ingredients		=	[],
			recette			=	"(FTVER='',FRNUM='"+ duplicateModel.getProperty( "/SRNUM" ) +"')",
			thisOverview	=	this,
			param			=	null;
		
		service.read( "/RecetteSet" + recette  , {
			urlParameters	: 	"$expand=RC2IN,RC2VR,RC2TX,RC2EN,RC2TP,RC2VL,RC2IM",
         	async			:	false,
         	success			:	function( oData ) {
         		for (var i=0; i<oData.RC2VR.results.length; i++) {
	            	if( oData.RC2VR.results[i].SRTFT ){
	            		oData.RC2VR.results[i].APDEB = duplicateModel.getProperty( "/APDEB" );	
	            		oData.RC2VR.results[i].APFIN = "99991231";
	            		version	=	oData.RC2VR.results[i];
	            		flag	=	true;
	            	}
	            }
	            for ( i = 0; i < oData.RC2IN.results.length && flag; i++) {
	            	if( oData.RC2IN.results[i].FTVER === version.FTVER ){
	            		ingredients.push( oData.RC2IN.results[i] );
	      //      		if( oData.RC2IN.results[i].MATNR.includes( "AF" ) || oData.RC2IN.results[i].MATNR.includes( "SR" ) ){
	      //      			var oBundle 	= 	thisOverview.getView().getModel("i18n").getResourceBundle(),
							// 	versionDialog	= new sap.m.Dialog({
							// 		title: oBundle.getText( "NEW_ALERTE" ),
							// 		type: 'Message',
							// 		content: new sap.m.Text({ text: oBundle.getText( "CONTAIN_FICTIF" ) }),
						
							// 		endButton: new sap.m.Button({
							// 			icon : "sap-icon://decline",
							// 			type: "Reject",
							// 			press: function () {
							// 				versionDialog.close();
							// 			}
							// 		}),
							// 		afterClose: function () {
							// 			versionDialog.destroy();
							// 		}
							// 	});
							// 	versionDialog.open();
							// return;	
	      //      		}
	            	}
	            }
		    	if( !flag ){
			      	var oBundle 	= 	thisOverview.getView().getModel("i18n").getResourceBundle(),
						versionDialog	= new sap.m.Dialog({
							title: oBundle.getText( "NEW_ALERTE" ),
							type: 'Message',
							content: new sap.m.Text({ text: oBundle.getText( "VERSION_ALERTE" ) }),
				
							endButton: new sap.m.Button({
								icon : "sap-icon://decline",
								type: "Reject",
								press: function () {
									versionDialog.close();
								}
							}),
							afterClose: function () {
								versionDialog.destroy();
							}
						});
						versionDialog.open();
					return;	
			      }else{
	            	thisOverview.getView().getModel( "DuplicateVersion" ).setData( [ version , ingredients ] );
			      	param		=	{ "Recette": "(FTVER='',FRNUM='" + duplicateModel.getProperty( "/FRNUM" ) + "')"};
					//Routing
					thisOverview.navigationTo( "Detail", param, false );
			      }
             },
             error: function( error ) {
                   
             }
          });
	      
	},
	formatDate:function( date ){
		if( date.length < 2 ){
			date = "0" + date;
		}
		return date;
	},
	toDate:function( value ){
		return new Date( value.substring(0,4) + "-" + value.substring(4,6) + "-" + value.substring(6,8) );
	},
	
	toDateString:function( date ){
		var mounth		=	this.formatDate( date.getMonth() + 1 + "" ),
			day			=	this.formatDate( date.getUTCDate() + "" );
		return date.getFullYear() + mounth + day;	
	},
	onDateChange: function( event ){
		var model	=	this.getView().getModel( "Duplicate" ),
			value	=	model.getProperty( "/APDEB" ),
			date	=	new Date();
		date.setDate( date.getDate + 1 );
		value	=	value;
		date	=	this.toDateString( date );
		if( Number( value ) < Number( date ) ){
			model.setProperty( "/APDEB", date );
		}
	},
	RecetteList:function( event ){
		if( !this._recetteList ){
			this._recetteList = sap.ui.xmlfragment( "CatalogRecette.Fragment.RecetteList", this);
			this.getView().addDependent(this._recetteList);
		}
		this._recetteList.open();
	},
	
	handleRecetteSearch: function(oEvent) {
		var sValue		= oEvent.getParameter("value"),
			oBinding	= oEvent.getSource().getBinding("items");

		if( sValue ) {
			sValue		= sValue.toUpperCase();
		}
		
		this.handleDialogSearch(sValue, "TITRE", oBinding);
	},
	/**
	 * LiveChange dialog list
	 * for check if the have value
	 */
	// checkValue: function( event ){
	// 	this.setInputState( event.getSource() );
	// },

	handleDialogSearch: function(value, name, binding) {
		var NameFilter = new sap.ui.model.Filter(name, sap.ui.model.FilterOperator.Contains, value);
		binding.filter(NameFilter);
	},
	closeRecetteList: function( oEvent ){
		var binding	=	oEvent.getSource().getBinding("items");
		this.handleDialogSearch("", "TITRE", binding);
		// this._recetteList.close();
	},
	confirmRecette: function( event ){
		var items	=	event.getParameter("selectedItem"),
			model	=	this.getView().getModel( "Duplicate" ),
			frnum	=	items.getDescription(),
			titre	=	items.getTitle();
		model.setProperty( "/FRNUM", frnum );
		model.setProperty( "/TITRE", titre );
	},

	checkDate:function( event ){
		var model	=	this.getView().getModel( "Duplicate" ),
			apdeb	=	model.getProperty( "/APDEB" ),
			date	=	new Date(),
			nDate	=	this.toDateString(date);
		date.setDate( date.getDate() + 1 );
		if( Number( apdeb ) <= Number( nDate ) ){
			model.setProperty( "/APDEB" , this.toDateString( date ) );
		}
	},
	
	// onCollapseAll: function () {
 //           var oTreeTable = this.getView().byId("Table");
 //           oTreeTable.collapseAll();
 //           this.byId( "expandButton" ).setVisible( true );
 //           this.byId( "collapseButton" ).setVisible( false );
 //       },
 
 //       onExpandFirstLevel: function () {
 //           var oTreeTable = this.getView().byId("Table");
 //           oTreeTable.expandToLevel(1);
 //           this.byId( "expandButton" ).setVisible( false );
 //           this.byId( "collapseButton" ).setVisible( true );
 //       },
	
	treeModel: function ( model ){
		if( !model.items ){
			var articleTab 	= model.reduce( function( result , item ) {
									if( !result[item.FRNUM] ) {
										result[item.FRNUM]			=	{};
										result[item.FRNUM].FRNUM	=	item.FRNUM;
										result[item.FRNUM].TITRE	=	item.MAKTX;
										result[item.FRNUM].CNFIC	=	item.CNFIC;
										result[item.FRNUM].ISFIC	=	item.ISFIC;
										result[item.FRNUM].TSTAT	=	item.TSTAT;
										result[item.FRNUM].FAMIL	=	item.FAMIL;
										result[item.FRNUM].FAMTX	=	item.FAMTX;
										result[item.FRNUM].VALOR	=	item.VALOR;
										result[item.FRNUM].NBING	=	item.NBING;
										result[item.FRNUM].TMPPR	=	item.TMPPR;
										result[item.FRNUM].NBGST	=	item.NBGST;
										result[item.FRNUM].IMSRC	=	item.IMSRC;
										result[item.FRNUM].FTVER	=	item.FTVER;
										result[item.FRNUM].SRTFT	=	item.SRTFT;
										result[item.FRNUM].items 	=	[];
									}
									if( !result[item.FRNUM].SRTFT && item.SRTFT ){
										result[item.FRNUM].CNFIC	=	item.CNFIC;
										result[item.FRNUM].ISFIC	=	item.ISFIC;
										result[item.FRNUM].TSTAT	=	item.TSTAT;
										result[item.FRNUM].FAMIL	=	item.FAMIL;
										result[item.FRNUM].FAMTX	=	item.FAMTX;
										result[item.FRNUM].VALOR	=	item.VALOR;
										result[item.FRNUM].NBING	=	item.NBING;
										result[item.FRNUM].TMPPR	=	item.TMPPR;
										result[item.FRNUM].NBGST	=	item.NBGST;
										result[item.FRNUM].FTVER	=	item.FTVER;
										result[item.FRNUM].IMSRC	=	item.IMSRC;
										result[item.FRNUM].SRTFT	=	item.SRTFT;
									}else if( !result[item.FRNUM].SRTFT ){
										result[item.FRNUM].CNFIC	=	item.CNFIC;
										result[item.FRNUM].ISFIC	=	item.ISFIC;
										result[item.FRNUM].TSTAT	=	item.TSTAT;
										result[item.FRNUM].FTVER	=	item.FTVER;
										result[item.FRNUM].FAMIL	=	item.FAMIL;
										result[item.FRNUM].FAMTX	=	item.FAMTX;
										result[item.FRNUM].VALOR	=	item.VALOR;
										result[item.FRNUM].NBING	=	item.NBING;
										result[item.FRNUM].TMPPR	=	item.TMPPR;
										result[item.FRNUM].NBGST	=	item.NBGST;
										result[item.FRNUM].IMSRC	=	item.IMSRC;
										result[item.FRNUM].SRTFT	=	item.SRTFT;
									}
									result[item.FRNUM].items.push( item );
									return result;
								} , {});
			var data 	=	{},
				stat	=	false;

			for (var key in articleTab) {
				if( !data.items ){
			  		data.items = [];
			  	}
			  	if(articleTab[key].items.length < 2  ){
			  		data.items.push(articleTab[key].items[0] );
			  	}else{
					data.items.push( articleTab[key]);
			  	}
			}
			data.needRestore = true;
		}
			return data;

	},
	
	/**
	 * Initialistion of newproduct popUp
	 */
	onNewRecipe: function( event ){
		var source			=	event.getSource(),
			buttonId		=	source.getId(),
			actionSheetTitle=	source.getParent().getTitle(),
			param			=	null,
			routeName		=	null,
			version 		=	this.byId("withVersion").getSelectedKey(),
			tableId			=	"GTable";
		if( version === "true" ){
			tableId 		=	"Table";
		}
		if( actionSheetTitle.includes( "Nouvelle" ) ){
			routeName		=	"NouvelleRecette";
			param			=	{"Recette"	:	this.defineRecipeType( buttonId )};
			
		}else{
			var table		=	this.byId(tableId),
				path		=	table.getSelectedIndex(),
				srvPath		=	table.getContextByIndex(path).getPath(),
				recettePath	=	srvPath.split("Set")[1];
			if( version === "true" ){
				var item	=	this.getView().getModel( "articleTable" ).getProperty( srvPath );
				recettePath =	"(FRNUM='" + item.FRNUM + "',FTVER='" + item.FTVER + "')";
				tableId		=	"Table";
			}	
				
			routeName		=	"DuplicationRecette";
			param			=	{"Recette"	:	recettePath + this.defineRecipeType( buttonId )};
		}
		this.getView().getModel( "DuplicateVersion" ).setData( {} );
	 	this.navigationTo( routeName, param, false );
	},
	
	defineRecipeType: function( buttonId ){
		if( buttonId.includes( "FicheTechnique" ) ){
				return	"FT";
			}else{
				return	"SR";
			}
	},
	
	/**
	 * Close newProduct popUp
	 * and reset the init dialog
	 */
	onCloseInitDialog: function( elements ){
		if( this._initDialog.getContent()[0].getAggregation("form") ){
			if( !Array.isArray( elements ) ){
				elements = this._initDialog.getContent()[0].getAggregation("form").getAggregation("formContainers")[0].getAggregation("formElements");
			}
			for (var i = 1; i < elements.length-1; i++) {
				elements[i].getAggregation("fields")[0].setValueState( sap.ui.core.ValueState.Default );
				elements[i].getAggregation("fields")[0].setValue( "" );
			}
			elements[0].getAggregation("fields")[0].setValue( "" );
			elements[7].getAggregation("fields")[0].setSelected( false );
		}
		this._initDialog.close();	
	},
	/**
	 * LiveChange on initNewArticle popUp
	 * for check if the have value
	 */
	checkValue: function( event ){
		this.setInputState( event.getSource() );
	},
	/**
	 * Check if the field have value
	 * if true change input color to defaul color
	 * else change the input color to error color
	 */
	setInputState: function( field ){
		if( field.getValue() === "" ){
			field.setValueState( sap.ui.core.ValueState.Error );
			this.flag = true;
		}else{
			field.setValueState( sap.ui.core.ValueState.Default );
		}
	},

	/**
	 * Open the dialog of Article copy list 
	 */
	onArticleCopyList: function( oController ){
		this.inputId 	= 	oController.oSource.sId;
		// var ArtSrv 				= 	this.getView().getModel( "ArtService" );

	    // create value help dialog
	    if (!this._ArticleCopyDialog) {
	      this._ArticleCopyListDialog = sap.ui.xmlfragment(
	        	"CatalogRecette.Fragment.ArticleCopyList",
	        	this
	      	);
	    	this.getView().addDependent(this._ArticleCopyListDialog);
	    }

	    this._ArticleCopyListDialog.open();
	},

	closeArticleCopy: function() {
		this._ArticleCopyListDialog.close();	
	},

	/**
	 * routing to the article's detail view
	 */
	onPressArticle: function( event ) {
		
		var source		=	event.getSource(),
			binding		=	source.getBindingInfo( "text" ).binding,
			path		=	binding.getContext().getPath(),
			version		=	this.getView().getModel( "Overview" ).getProperty( "/Version" ),
			param		=	null,
			display		=	this.getView().getModel( "Edit" ).getProperty( "/Display" );
		if( display ){
			if( version === "true" ){
				var model	=	this.getView().getModel( "articleTable" ).getProperty( path );
				param		=	{ "Recette": "(FTVER='" + model.FTVER +"',FRNUM='" + model.FRNUM + "')"};
			}else{
				param		=	{ "Recette": path.split( "Set" )[ 1 ] };
			}
				
			this.getView().getModel( "DuplicateVersion" ).setData( {} );
			//Routing
			this.navigationTo( "Detail", param, false );
		}
	},

	onSelectedRow:function (){
		var version 	=	this.byId( "withVersion" ).getSelectedKey(),
			nbSelected 	=	null,
			duplicate 	=	this.byId( "duplicateButton" ),
			create		=	this.getView().getModel( "Edit" ).getProperty( "/Create" );
		if( create ){
			if( version === "true" ){
				nbSelected = this.byId( "Table" ).getSelectedIndices().length;	
			}else{
				nbSelected = this.byId( "GTable" ).getSelectedIndices().length;	
			}
			if( nbSelected === 1 ){
				duplicate.setVisible( true );
			}else{
				duplicate.setVisible( false );
			}
		}
	},

	onImagePreview:function ( event ){
		var source 	=	event.getSource(),
			model	=	this.getView().getModel("CatRectService"),
			path	=	source.getParent().getBindingContext("CatRectService").getPath(),
			URL 	=	source.getSrc(),
			artNum	=	model.getObject(path).TITRE;

		if( !this._previewImageDialog ){
			this._previewImageDialog = sap.ui.xmlfragment( "CatalogRecette.Fragment.imageDialog", this);
			this.getView().addDependent(this._previewImageDialog);
		}
	 	this._previewImageDialog.open();

	 	this._previewImageDialog.setTitle( artNum );

		var image 		=	this._previewImageDialog.getAggregation("content")[0];
		image.setSrc( URL );
		image.setWidth( "400px" );

	},

	closeDialog:function(){
		this._previewImageDialog.close();
	},

	/**
	 * Navigate to detail page
	 *
	 * @param      {<type>}  Page       The page
	 * @param      {<type>}  Parameter  The Article Number
	 * @param      {<type>}  Bool       false
	 */
	navigationTo: function ( Page, Parameter, Bool ) {
		var router 			= 	sap.ui.core.UIComponent.getRouterFor( this.getView() );
		router.navTo( Page, Parameter, Bool );
	},

	_buildFilters: function () {
		var filterData 		=	this.getView().getModel( "QuickFilter" ).getData(),
			filters 		=	[],
			multi			=	this.byId( "multiIngredients" ).getTokens(),
			multiFilter	,
			i,
			customFilter	=	null,
			service			=	this.getView().getModel( "CatRectService" ),
			check			=	false,
			nRecette		=	false,
			thisOverview	=	this;
		
		if ( filterData.Recette.length >= 1 ){
			if( filterData.Recette.toUpperCase().startsWith( "FT" ) || filterData.Recette.toUpperCase().startsWith( "SR" ) ){
				filters.push( new sap.ui.model.Filter( "FRNUM" , sap.ui.model.FilterOperator.StartsWith , filterData.Recette ) );
				if ( filterData.Recette.length > 5 ){
					check	=	true;
				}else{
					check	=	false;
				}
			}else{
				nRecette = true;
			}
		}
		
		
		
		if ( filterData.Designation ) {
			//	Filter on reference number
			filters.push(	new sap.ui.model.Filter( "TITRE" , sap.ui.model.FilterOperator.Contains , filterData.Designation ) );	
			if( filterData.Designation.length > 2 ){
				check	=	true;
			}else{
				check	=	false;
			}
		}
		
		if( filterData.Carte ) {
			customFilter	=	new sap.ui.model.Filter( "CTNUM" , sap.ui.model.FilterOperator.Contains , filterData.Carte.split( " - " )[1] );
			// if( this.getView().getModel( "Overview" ).getData().Version === "true" ){
			// 	service.read( "/RecetteSet()"  , {
			// 		filters			:	[ customFilter ],
		 //        	async			:	false,
		 //        	success			:	function( oData ) {
		 //        		thisOverview.getView().getModel( "articleTable" ).setData( thisOverview.treeModel( oData.results ) );
		 //        	},
		 //        	error			:	function(){
		         		
		 //        	}
		 //        });
			// }else{
				//	Filter on reference number
				filters.push(	new sap.ui.model.Filter( "CTNUM" , sap.ui.model.FilterOperator.Contains , filterData.Carte.split( " - " )[1] ) );	
			// }
			check	=	true;
		}
		
		if( multi.length > 0 ) {
			customFilter	=	[];
			if( this.getView().getModel( "Overview" ).getData().Version === "true" ){
				for (i = 0; i < multi.length; i++ ) {
					customFilter.push( new sap.ui.model.Filter( "MATNR" , sap.ui.model.FilterOperator.EQ , multi[i].getKey() ) );
				}
				this.byId( "customFilterButton" ).setType( "Emphasized" );
				
			}else{
				//	Filter on reference number
				for (i = 0; i < multi.length; i++ ) {
					customFilter.push( new sap.ui.model.Filter( "MATNR" , sap.ui.model.FilterOperator.EQ , multi[i].getKey() ) );
				}
				this.byId( "customFilterButton" ).setType( "Emphasized" );
				filters.push( new sap.ui.model.Filter( customFilter, false) );
			}
			check	=	true;
		
		}else{
			this.byId( "customFilterButton" ).setType( "Default" );
		}

		if( filterData.Family && filterData.Family.length > 0) {
			multiFilter = [];
			for (i = 0; i < filterData.Family.length; i++) {
				multiFilter.push( new sap.ui.model.Filter(  "FAMTX" , sap.ui.model.FilterOperator.StartsWith , filterData.Family[i] ) );
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			//	Filter on reference number
			if( filters.length	>	1 ){
				check	=	true;
			}else{
				check	=	false;
			}
		}


		if( filterData.Enseigne && filterData.Enseigne.length > 0 ) {
			//	Filter on reference number
			multiFilter = [];
			for (i = 0; i < filterData.Enseigne.length; i++) {
				multiFilter.push( 	new sap.ui.model.Filter( "ENSGN" , sap.ui.model.FilterOperator.EQ , filterData.Enseigne[i] ) );	
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			if( filters.length	>	1 ){
				check	=	true;
			}else{
				check	=	false;
			}
		}

		if( filterData.Status && filterData.Status.length > 0  ) {
			//	Filter on reference number
			multiFilter = [];
			for (i = 0; i < filterData.Status.length; i++) {
				multiFilter.push( new sap.ui.model.Filter( "STATS" , sap.ui.model.FilterOperator.EQ , filterData.Status[i] ) );	
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			
			if( filters.length	>	1 ){
				check	=	true;
			}else{
				check	=	false;
			}
		}
		
		if( this.paramFilter ){
			filters.push( new sap.ui.model.Filter( "MATNR" , sap.ui.model.FilterOperator.EQ ,this.paramFilter) );
		}

		return [ filters , check, nRecette ];
	},

	handleSearch: function(){
		var binding 			=	null,
			result				=	this._buildFilters(),
			filters				=	result[0],
			check				=	result[1],
			nRecette			=	result[2],
			version				=	this.getView().getModel("Overview").getData().Version,
			treeTable   		=	this.byId("Table"),
			table				=	this.byId("GTable");

		
		if( version === "true" ){
			table.setVisible( false );
			treeTable.setVisible( true );
		}else{
			table.setVisible( true );
			treeTable.setVisible( false );
		}
		
		if( version === "true" ){
			binding = treeTable.getBinding("rows");
			binding.filter( null );
			
			// if( filters.length > 0 && check ) {
				this.loadByVersion();
			// }
		}else{
			binding = table.getBinding("rows");
			var carte	=	this.getView().getModel( "QuickFilter" ).getProperty( "/Carte" );
			
			if( filters.length > 0 && check  ){
				binding.filter( new sap.ui.model.Filter( filters, true) );
				this.byId( "addCritere" ).setVisible( false );
				this.byId( "completeCarteId" ).setVisible( false );
			}else if( ( filters.length > 0 && !check ) || nRecette ){
				this.byId( "addCritere" ).setVisible( true );
				this.byId( "completeCarteId" ).setVisible( false );
			}else if( carte && carte.length > 0 && !check ){
				this.byId( "addCritere" ).setVisible( false );
				this.byId( "completeCarteId" ).setVisible( true );
			}else{
				this.byId( "addCritere" ).setVisible( false );
				this.byId( "completeCarteId" ).setVisible( false );
				binding.filter( null );
			}
		}
	},
	addFilter: function(){
		var filter	=	this.byId( "customFilter" );
		
		if( filter.getVisible() ){
			filter.setVisible( false );
		}else{
			filter.setVisible( true );
		}
	}
});