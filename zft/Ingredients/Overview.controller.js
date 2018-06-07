jQuery.sap.require("sap/ui/model/Filter");
jQuery.sap.require("sap/ui/model/FilterOperator");
jQuery.sap.require("CatalogMat/util/Formatter");
jQuery.sap.require("sap/ui/table/SortOrder");
jQuery.sap.require("sap/ui/model/Sorter");
// jQuery.sap.require(	"XCUI/app/catalogMat/util/Formatter" );

sap.ui.controller("CatalogMat.Controller.Overview", {
	/**
	 * Called when a controller is instantiated and its View controls (if available) are already created.
	 * Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
	 * @memberOf test.detail
	 */

	Formatter: CatalogMat.util.Formatter,
	flag: false,
	thisOverview: null,
	onInit: function() {
		this.getView().addStyleClass("sapUiSizeCompact");

		thisOverview = this;
		//	Routing
		this.router = sap.ui.core.UIComponent.getRouterFor(this);
		this.router.attachRoutePatternMatched(this.handleRouting, this);
		this._BusyDialog = sap.ui.xmlfragment(
			"CatalogMat.Fragment.BusyDialog",
			this
		);
		this.getView().addDependent(this._BusyDialog);
		this.InitModels();

		// this.byId("fournisseurInput").setFilterFunction(function(sTerm, oItem) {
		// 		// A case-insensitive 'string contains' style filter
		// 		return oItem.getText().match(new RegExp(sTerm, "i"));
		// });
	},
	/**
	 * Models initialization
	 */
	InitModels: function() {

		// Article Data model
		this.getView().setModel(new sap.ui.model.json.JSONModel(), "articleTable");

		// Filter model
		this.getView().setModel(new sap.ui.model.json.JSONModel( {
			Article	: "",
			Designation : ""
		} ), "QuickFilter");

		// NewProduct model
		this.getView().setModel(new sap.ui.model.json.JSONModel({
			"MATNR": "",
			"DESCP": "",
			"BUYER": "",
			"CTNUM": "",
			"MAKTX": "",
			"MEINS": "",
			"SRCLC": false,
			"TARAP": "",
			"NAVIG": false
		}), "NewProduct");
		// status newProduct model
		this.getView().setModel(new sap.ui.model.json.JSONModel(), "NewProductStats");

		this.getView().setModel(new sap.ui.model.json.JSONModel({
			"Version": "false"
		}), "Overview");
		
		var	filter	=	this.getOwnerComponent().getComponentData();          
		if( filter ){
			if( filter.startupParameters.stats ){
				// this.byId("GTable").getBinding("rows").filter( [new sap.ui.model.Filter({	path: "STATS",
				// 																			operator: sap.ui.model.FilterOperator.EQ,
				// 																			value1: filter.startupParameters.stats[0]
				// 																		})] );	
				this.getView().getModel("QuickFilter").getData().Status = 	[filter.startupParameters.stats[0]];
				// this.handleSearch();
				this.VHModelsInit( true );
			}
			else if ( 	filter.startupParameters.MATNR && filter.startupParameters.MATNR[0] ) {
				var matnr	=	filter.startupParameters.MATNR[0].split( "-" )[0];
				this.navigationTo("Detail", { "Article": "(MATNR='" + matnr + "',MFRNR='')"}, true ) ;
				this.VHModelsInit( false );
				// filter.startupParameters.FRNUM = false;
				return;
			}else{
				this.VHModelsInit( false );
			}
		}else{
			this.VHModelsInit( false );
		}
		this.init	=	true;

	},
	handleRouting: function(event) {
		if( event.getParameter( "name" ) === "Overview" && !this.init ){
			this.handleSearch();
		}
		if( this.init ){
			this.init	=	false;
		}
	},
	
		
	VHModelsInit: function( check ){
		var service 		= 	this.getOwnerComponent().getModel( "CatMatService" ),
			that 			=	this;
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VhFamily" );
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VhTypology" );
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VhStatut" );
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VhTemperature" );
		
		// if( check ){
		// 	this.selectAll(false, "Distributeur", true);
		// }
		service.read( "/VHFamillesSet",{    
			success: function( oData ) {
		        that.getView().getModel( "VhFamily" ).setData( oData.results );
		  //      var field		=	that.getView().byId( "FamilyList" ),
				// 	items		=	[];
	   //     	jQuery.each( oData.results , function( key, value ) {
				// 	if( !value.CLASS.includes( "NOA" ) ){
				// 		items.push( value.KSCHL );
				// 	}
				// });
				// field.setSelectedKeys( items );
				// serverDone[0] = true;
				// that.callSearchServer( serverDone );
				// that.checkAllSelected( false, "FamilyList" );
		    },
		    error: function( error ) {
		    }
    	});
    	
    
		service.read( "/VHTypologiesSet",{    
			success: function( oData ) {
		        that.getView().getModel( "VhTypology" ).setData( oData.results );
				// if( check ){
				// 	that.selectAll(false, "Typology", true);
				// }
				// serverDone[0] = true;
				// that.callSearchServer( serverDone );
		    },
		    error: function( error ) {
		    }
    	});
    	
		service.read( "/VHMPStatusSet",{    
			success: function( oData ) {
		        that.getView().getModel( "VhStatut" ).setData( oData.results );
		        var field		=	that.getView().byId( "StatusList" );
					// list		=	field.getItems(),
					// items		=	[];
		        if( check ){
					// jQuery.each( list , function( key, value ) {
					// 	if( value.getKey() !== "1" && value.getKey() !== "50" ){
					// 		items.push( value.getKey() );
					// 	}
					// });
					// field.setSelectedKeys( items );
					// // that.handleSearch();
					// that.checkAllSelected( false, "StatusList" );
		   //     }else{
		        	field.setSelectedKeys( that.getView().getModel("QuickFilter").getData().Status[0] );
					that.handleSearch();
					that.checkAllSelected( false, "StatusList" );
		        }
		   //     serverDone[1] = true;
		   //     that.callSearchServer( serverDone );
		    },
		    error: function( error ) {
		    }
    	});
    	
    	service.read( "/VHTempbSet",{    
			success: function( oData ) {
		        that.getView().getModel( "VhTemperature" ).setData( oData.results );
		  //      var field		=	that.getView().byId( "TemperatureList" ),
				// 	list		=	field.getItems(),
				// 	items		=	[];
	   //     	jQuery.each( list , function( key, value ) {
				// 	if( value.getKey() !== "NO" ){
				// 		items.push( value.getKey() );
				// 	}
				// });
				// field.setSelectedKeys( items );
				// // that.handleSearch();
				// that.checkAllSelected( false, "TemperatureList" );
				// serverDone[3] = true;
				// that.callSearchServer( serverDone );
		    },
		    error: function( error ) {
		    }
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
		if( screenR < 800 ){
			edit.setProperty( "/Screen" , 14 );
		}else if( screenR >	800	&& screenR	<	850 ){
			edit.setProperty( "/Screen" , 15 );
		}else if( screenR >	850	&& screenR	<	900 ){
			edit.setProperty( "/Screen" , 16 );
		}else{
			edit.setProperty( "/Screen" , 17 );
		}	
	},
	
	callSearchServer: function( serverDone ){
		if( !serverDone.includes( false ) ){
			this.handleSearch();
		}
	},
	
	onVersionClick: function(event) {
		var thisOverview = this,
			key = event.getSource().getSelectedKey();

		if (key === "true") {
			// this.getView().setBusy(true);
			// service.read("/ArticleSet()", {
			// 	filters: [new sap.ui.model.Filter({
			// 		path: "SRCVS",
			// 		operator: sap.ui.model.FilterOperator.EQ,
			// 		value1: true
			// 	})],
			// 	success: function(oData) {
			// 		thisOverview.getView().getModel("articleTable").setData(thisOverview.treeModel(oData.results));

			// 		thisOverview.getView().getModel("articleTable").setSizeLimit( oData.results.length + 100 );

			// 		thisOverview.getView().setBusy(false);

			// 		thisOverview.handleSearch();
			// 	},
			// 	error: function(error) {
			// 		thisOverview.getView().setBusy(false);
			// 	}
			// });
			thisOverview.byId("expandButton").setVisible(true);
			thisOverview.byId("collapseButton").setVisible(false);
		}
		// var model	=	this.getView().getModel( "QuickFilter" );
		// if( model.getProperty( "/Actif" ) === "R" ){
		// 	model.setProperty( "/Actif", false );
		// }else if( model.getProperty( "/Actif" ) === "F" ){
		// 	model.setProperty( "/Actif", true );
		// }else if( model.getProperty( "/Actif" ) === false ){
		// 	model.setProperty( "/Actif", "R" );
		// }else if( model.getProperty( "/Actif" ) === true ){
		// 	model.setProperty( "/Actif", "F" );
		// }else{
		// 	model.setProperty( "/Actif", "" );
		// }
		this.handleSearch();
	},

	onCollapseAll: function() {
		var oTreeTable = this.getView().byId("Table");
		oTreeTable.collapseAll();
		this.byId("expandButton").setVisible(true);
		this.byId("collapseButton").setVisible(false);
	},

	onExpandFirstLevel: function() {
		var oTreeTable = this.getView().byId("Table");
		oTreeTable.expandToLevel(1);
		this.byId("expandButton").setVisible(false);
		this.byId("collapseButton").setVisible(true);
	},

	treeModel: function(data) {
		if (!data.items) {
			var articleTab = data.reduce(function(result, item) {
				if (!result[item.RMATN]) {
					result[item.RMATN] = {};
					result[item.RMATN].isGroup = true;
					result[item.RMATN].items = [];
				}
				if( item.ISPRT ){
					result[item.RMATN].MATNR = item.MATNR;
					result[item.RMATN].MAKTX = item.MAKTX;
					result[item.RMATN].DISTT = item.DISTT;
					result[item.RMATN].DISTB = item.DISTB;
					result[item.RMATN].TEMPB = item.TEMPB;
					result[item.RMATN].TBTXT = item.TBTXT;
					result[item.RMATN].NTGEW = item.NTGEW;
					result[item.RMATN].VLCRN = item.VLCRN;
					result[item.RMATN].DCDTD = item.DCDTD;
					result[item.RMATN].TSTAT = item.TSTAT;
					result[item.RMATN].KBETR = item.KBETR;
					result[item.RMATN].MEINS = item.MEINS;
					result[item.RMATN].IMSRC = item.IMSRC;
					result[item.RMATN].MFRNR = item.MFRNR;
					result[item.RMATN].TARAP = item.TARAP;
					result[item.RMATN].ERSDA = item.ERSDA;
					result[item.RMATN].ISPRT = item.ISPRT;
					result[item.RMATN].FICTF = item.FICTF;
				}
				
				result[item.RMATN].items.push(item);
				
				return result;
			}, {});
			var data = {};

			for (var key in articleTab) {
				if (!data.items) {
					data.items = [];
				}
				if (articleTab[key].items.length < 2) {
					data.items.push(articleTab[key].items[0]);
				// } else if(articleTab[key].items[0].ISPRT){
				// 	var temp	=	[];
				// 	for (var i = 1; i < articleTab[key].items.length; i ++) {
				// 		articleTab[key].items[i].ARTTY	= "R";
				// 		temp.push( articleTab[key].items[i] );
				// 	}
				// 	articleTab[key].items = temp;
				// 	articleTab[key].DCDTD = "";
				// 	data.items.push( articleTab[key] );
				}else {
					// articleTab[key].DCDTD = "";
					data.items.push(articleTab[key]);
				}
			}
			data.needRestore = true;
		}
		return data;

	},

	onClearFilter: function() {

		this.getView().getModel("QuickFilter").setData(	{
															Article	: "",
															Designation : ""
															});
		this.byId( "FamilyLi" ).setVisible( true );
		this.byId( "TypologyLi" ).setVisible( true );
		this.byId( "DistributeurLi" ).setVisible( true );
		this.byId( "TemperatureLi" ).setVisible( true );
		this.byId( "StatusLi" ).setVisible( true );
		this.handleSearch();
	},

	/**
	 * Initialistion of newproduct popUp
	 */
	NewProductPress: function() {
		if (!this._initDialog) {
			this._initDialog = sap.ui.xmlfragment("CatalogMat.Fragment.initNewArticleDialog", this);
			this.getView().addDependent(this._initDialog);
		}
		this.getView().getModel("NewProductStats").setProperty("/MEINS", false);
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
		newProduct.setProperty("/NAVIG", false);
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
		this.handleSearch();
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
		that._BusyDialog.open();
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
			that._BusyDialog.close();
			return;
		}else{
			delete newProductModel["__metadata"];
			delete newProductModel["DESCR"];
			var param = {
				method: "GET",
				async:	false,
				urlParameters: newProductModel,
				success: function(data) {
					that.param	=	{ "Article": "(MATNR='" + data.MATNR +"',MFRNR='" + data.MFRNR + "')"};
					var upload	=	false;
					if( oFileUploader.getValue() !== "" ){
						that.uploadPress(oFileUploader, data.MATNR, "I", oFileUploader.getValue(), "", newProductModel.DESFL);
						upload	=	true;
					}else{
						that.onCloseInitDialog();
					}
					//	Display message
					if (!data) {
						return;
					}
					that.getView().setBusy(false);
					that._BusyDialog.close();
					sap.m.MessageToast.show("L'article " + data.MATNR + " - " + data.MAKTX + " a  bien été créé");
					if( navig && !upload ){
						var parametre		=	{ "Article": "(MATNR='" + data.MATNR +"',MFRNR='" + data.MFRNR + "')"};
						that.navigationTo("Detail", parametre, false);
					}
				},
				error: function(error) {
					//	Disable busy indicator
					that._BusyDialog.close();
					
					//	Display message
					sap.m.MessageToast.show( JSON.parse(error.responseText).error.message.value );
				}
			};
	
			service.callFunction("/Article_Create", param);
		}
		
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
		// this.getView().setBusy( true );

		//	Upload Image
		oFileUploader.upload();
	},/**
	 * On Upload Complete
	 * @param  {jQuery.Event} oEvent 
	 */
	uploaderUploadComplete: function( oEvent ) {
		var oView 			=	this.getView(),
			vStatus 		=	oEvent.getParameter( "status" ),
			oBundle 		=	oView.getModel( "i18n" ).getResourceBundle(),
			that			=	this,
			navig			=	this.getView().getModel("NewProductStats").getProperty( "/NAVIG" );
			
	
		// //	Build Filter for Article Number
		
		// 	var filter 		= new sap.ui.model.Filter({ 
		// 		path 	: 	"OBJNR",
		// 		operator: 	sap.ui.model.FilterOperator.EQ,  
		// 		value1 	: 	vArtNum
		// 	});
		

		if ( vStatus === 201 || vStatus === 200 ) {
			//	Free the View
			that._BusyDialog.close();
			sap.m.MessageToast.show( oBundle.getText( "UPLOAD_SUCCESS" ) );
			if( navig ){
				that.navigationTo("Detail", that.param, false);
			}
		
		} else {
			//	Free the View
			that._BusyDialog.close();
			//	Error Message
			sap.m.MessageToast.show( oBundle.getText( "UPLOAD_FAILLED" ) );
		}
		that.onCloseInitDialog();
	},
	/**
	 * LiveChange on initNewArticle popUp
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

	/**
	 * Check if the field have value
	 * if true change input color to defaul color
	 * else change the input color to error color
	 * work on since release 1.40.2
	 */
	// checkValueSelect: function( event ){
	// 	var field	=	event.getSource();
	// 	if( field.getSelectedKey() === "" ){
	// 		field.setValueState( sap.ui.core.ValueState.Error );
	// 		this.flag = true;
	// 	}else{
	// 		field.setValueState( sap.ui.core.ValueState.Default );
	// 	}
	// },
	onImagePreview: function(event) {
		var source = event.getSource(),
			model = null,
			path = null,
			artNum = null,
			URL = source.getSrc();

		if (thisOverview.getView().getModel("Overview").getData().Version === "false") {
			model = this.getView().getModel("CatMatService");
			path = source.getParent().getBindingContext("CatMatService").getPath();
			artNum = model.getObject(path).MAKTX;
		} else {
			model = this.getView().getModel("articleTable").getData();
			path = source.getParent().getBindingContext("articleTable").getPath().split("/");

			if (!path.items) {
				artNum = model.items[path[2]].MAKTX;
			} else {
				artNum = model.items[path[2]].items[path[4]].MAKTX;
			}
		}

		if (!this._previewImageDialog) {
			this._previewImageDialog = sap.ui.xmlfragment("CatalogMat.Fragment.imageDialog", this);
			this.getView().addDependent(this._previewImageDialog);
		}
		this._previewImageDialog.open();

		this._previewImageDialog.setTitle(artNum);

		var image = this._previewImageDialog.getAggregation("content")[0];
		image.setSrc(URL);
		image.setWidth("400px");

	},

	closeDialog: function() {
		this._previewImageDialog.close();
	},

	/**
	 * routing to the article's detail view
	 */
	onPressArticle: function(event) {

		var source		=	event.getSource(),
			binding		=	source.getBindingInfo( "text" ).binding,
			path		=	binding.getContext().getPath(),
			version		=	this.getView().getModel( "Overview" ).getProperty( "/Version" ),
			display		=	this.getView().getModel( "Edit" ).getProperty( "/Display" ),
			param		=	null;
		if( display ){
			if( version === "true" ){
				var model	=	this.getView().getModel( "articleTable" ).getProperty( path );
				param		=	{ "Article": "(MATNR='" + model.MATNR +"',MFRNR='" + model.MFRNR + "')"};
			}else{
				param		=	{ "Article": path.split( "Set" )[ 1 ] };
			}
			//Routing
			this.navigationTo("Detail", param, false);
		}
	},

	/**
	 * Open the dialog of Article copy list 
	 */
	onArticleCopyList: function(oController) {
		// create value help dialog
		if (!this._ArticleCopyListDialog) {
			this._ArticleCopyListDialog = sap.ui.xmlfragment(
				"CatalogMat.Fragment.ArticleCopyList",
				this
			);
			// var thisOverview = this;
			// // Article Data model
			// this.getView().setModel(new sap.ui.model.json.JSONModel(), "VHAllArticlesSet");
			// var service = this.getView().getModel("CatMatService");
			// this._BusyDialog.open();
			// service.read("/VHAllArticlesSet", {
			// 	success: function(oData) {
			// 		thisOverview.getView().getModel("VHAllArticlesSet").setSizeLimit( oData.results.length + 100 );
			// 		thisOverview.getView().getModel("VHAllArticlesSet").setData(oData.results);
			// 		thisOverview._BusyDialog.close();
			// 	},
			// 	error: function(error) {
			// 		thisOverview._BusyDialog.close();
			// 	}
			// });
			this.getView().addDependent(this._ArticleCopyListDialog);
		}
		this._ArticleCopyListDialog.open();
		var oBinding	= this._ArticleCopyListDialog.getAggregation( "_dialog" ).getContent()[1].getBinding( "items" ),
			NameFilter	= new sap.ui.model.Filter("MATNR", sap.ui.model.FilterOperator.EQ, "");
		oBinding.filter( NameFilter );

	},
	
	/**
	 * Open the dialog of Article copy list 
	 */
	onBuyerList: function(oController) {
		var that	=	this;
		// create value help dialog
		if (!this._BuyerListDialog) {
			this._BuyerListDialog = sap.ui.xmlfragment(
				"CatalogMat.Fragment.BuyerList",
				this
			);
			this.getView().addDependent(this._BuyerListDialog);
			this.getView().setModel(new sap.ui.model.json.JSONModel(), "VHAcheteursSet");
			var service = this.getView().getModel("CatMatService");
			this._BusyDialog.open();
			service.read("/VHAcheteursSet", {
				success: function(oData) {
					this.thisOverview.getView().getModel("VHAcheteursSet").setData(oData.results);
					that._BusyDialog.close();
				},
				error: function(error) {
					that._BusyDialog.close();
				}
			});
		}

		this._BuyerListDialog.open();
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
	},
	closeBuyerList: function( oEvent ){
		var binding 	=	oEvent.getSource().getBinding("items");
		binding.filter(new sap.ui.model.Filter("ACNUM", sap.ui.model.FilterOperator.Contains, ""));	
	},
	/**
	 * Search function of Article dialog
	 */
	handleBuyerSearch: function(oEvent) {
		var value		= oEvent.getParameter("value"),
			oBinding	= oEvent.getSource().getBinding("items"),
			NameFilter	= new sap.ui.model.Filter("FNAME", sap.ui.model.FilterOperator.Contains, value),
			CodeFilter	= new sap.ui.model.Filter("LNAME", sap.ui.model.FilterOperator.Contains, value),
			InfoFilter	= new sap.ui.model.Filter("ACNUM", sap.ui.model.FilterOperator.Contains, value),
			allFilter	= new sap.ui.model.Filter([NameFilter, CodeFilter, InfoFilter], false);
		
		oBinding.filter(allFilter);
	},
	
	/**
	 * Open the dialog of Article copy list 
	 */
	onOpeGammeList: function(oController) {

		// create value help dialog
		if (!this._CarteOpeListDialog) {
			this._CarteOpeListDialog = sap.ui.xmlfragment(
				"CatalogMat.Fragment.CarteOpeList",
				this
			);
			// Article Data model
			this.getView().setModel(new sap.ui.model.json.JSONModel(), "VHMenusSet");
			var service = this.getView().getModel("CatMatService");
			service.read("/VHMenusSet", {
				success: function(oData) {
					this.thisOverview.getView().getModel("VHMenusSet").setData(oData.results);
				},
				error: function(error) {

				}
			});
			this.getView().addDependent(this._CarteOpeListDialog);
		}

		this._CarteOpeListDialog.open();
	},

	confirmOpeGamme: function(event) {
		var value = event.getParameter("selectedItem"),
			newProduct = this.getView().getModel("NewProduct");

		newProduct.setProperty("/CTNUM", value.getDescription());
		newProduct.setProperty("/DESCR", value.getTitle());
	},

	confirmArticleCopy: function(event) {
		var value		=	event.getParameter("selectedItem"),
			newProduct	=	this.getView().getModel("NewProduct"),
			path		=	event.getParameter( "selectedContexts" )[0].getPath(),
			data		=	event.getParameter( "selectedContexts" )[0].getModel().getProperty( path );
		newProduct.setProperty("/MATNR", value.getDescription());
		
		newProduct.setProperty("/MEINS", data.MEINS);
		if( data.MATNR.includes( "AF" ) ){
			newProduct.setProperty("/DESCP", data.DESCP);
		}
		newProduct.setProperty("/TARAP", data.TARAP);
		newProduct.setProperty("/MAKTX", data.MAKTX);
		this._ArticleCopyListDialog.getAggregation( "_dialog" ).getAggregation( "subHeader" ).getAggregation( "contentMiddle" )[0].setValue( "" );
		
	},
	
	/**
	 * Search function of Article dialog
	 */
	handleArticleSearch: function(oEvent) {
		var sValue		= oEvent.getParameter("value").toUpperCase(),
			oBinding	= oEvent.getSource().getBinding("items"),
			NameFilter,
			allFilter,
			check		=	false;
		// if( sValue.startsWith( "AF" ) ){
		// 	if( sValue.length === 8 ){
		// 		check		= true;
		// 		NameFilter	= new sap.ui.model.Filter("MATNR", sap.ui.model.FilterOperator.EQ, sValue);
		// 		allFilter	= new sap.ui.model.Filter([NameFilter], false);
		// 	}
		// }else 
		if( sValue.length > 2 && isNaN( sValue.charAt(2) ) ){
			check		= true;
			NameFilter	= new sap.ui.model.Filter("MAKTX", sap.ui.model.FilterOperator.Contains, sValue);
			allFilter	= new sap.ui.model.Filter([NameFilter], false);
		}else if( sValue.length > 5 ){
			check		= true;
			NameFilter	= new sap.ui.model.Filter("MATNR", sap.ui.model.FilterOperator.StartsWith, sValue);
			allFilter	= new sap.ui.model.Filter([NameFilter], false);
		}else if( sValue.length === 0){
			check		=	true;
			allFilter	=	null;
		}
		
		
		if( check ){
			oBinding.filter(allFilter);
		}
	},

	/**
	 * Search function of Article dialog
	 */
	handleMenusSearch: function(oEvent) {
		var sValue = oEvent.getParameter("value"),
			oBinding = oEvent.getSource().getBinding("items");

		this.handleDialogSearch(sValue, "CTNUM", "DESCR", oBinding);
	},
	
	closeArticleCopy: function() {
		this._ArticleCopyListDialog.close();
	},

	/**
	 * Navigate to detail page
	 *
	 * @param      {<type>}  Page       The page
	 * @param      {<type>}  Parameter  The Article Number
	 * @param      {<type>}  Bool       false
	 */
	navigationTo: function(Page, Parameter, Bool) {
		var router = sap.ui.core.UIComponent.getRouterFor(this.getView());
		router.navTo(Page, Parameter, Bool);
	},

	_buildFilters: function(){
		var filterData = this.getView().getModel("QuickFilter").getData(),
			multiFilter,
			i,
			filters = [];
		//  ( filterData.Article.toUpperCase().startsWith( "AF" ) ||
		if (filterData.Article !== "" && filterData.Article.length > 5 ) {
			//	Filter on reference number
			filters.push(new sap.ui.model.Filter("MATNR", sap.ui.model.FilterOperator.StartsWith, filterData.Article));
			// if( !filterData.Article.toUpperCase().startsWith( "AF" ) || filterData.Article.length > 5 ){
				this.search	=	true;
			// }else{
			// 	this.search	=	false;
			// }
		}
		if (filterData.Designation && filterData.Designation.length > 2) {
			//	Filter on reference number
			filters.push(new sap.ui.model.Filter("MAKTX", sap.ui.model.FilterOperator.Contains, filterData.Designation));
			this.search	=	true;
		}
		
		

		if (filterData.Manufacturer	&& filterData.Manufacturer.length > 2) {
			//	Filter on reference number
			filters.push(new sap.ui.model.Filter("MFRNR", sap.ui.model.FilterOperator.Contains, filterData.Manufacturer));
			this.search	=	true;
		}

		if (filterData.Distributeur && filterData.Distributeur.length > 0  ) {
			//	Filter on reference number
			multiFilter = [];
			for (i = 0; i < filterData.Distributeur.length; i++) {
				multiFilter.push( new sap.ui.model.Filter( "DISTB" , sap.ui.model.FilterOperator.EQ , filterData.Distributeur[i] ) );	
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			if( filters.length	>	1 ){
				this.search	=	true;
			}else{
				this.search	=	false;
			}
		}

		if (filterData.Temperature && filterData.Temperature.length > 0  ) {
			//	Filter on reference number
			multiFilter = [];
			for (i = 0; i < filterData.Temperature.length; i++) {
				multiFilter.push( new sap.ui.model.Filter( "TEMPB" , sap.ui.model.FilterOperator.EQ , filterData.Temperature[i] ) );	
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			
			
			if( filters.length	>	1 ){
				this.search	=	true;
			}else{
				this.search	=	false;
			}
		}

		if (filterData.Family && filterData.Family.length > 0  ) {
			//	Filter on reference number
			multiFilter = [];
			for (i = 0; i < filterData.Family.length; i++) {
				multiFilter.push( new sap.ui.model.Filter( "WWGHB" , sap.ui.model.FilterOperator.Contains , filterData.Family[i] ) );	
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			if( filters.length	>	1 ){
				this.search	=	true;
			}else{
				this.search	=	false;
			}
		}

		if (filterData.Status && filterData.Status.length > 0  ) {
			//	Filter on reference number
			multiFilter = [];
			for (i = 0; i < filterData.Status.length; i++) {
				multiFilter.push( new sap.ui.model.Filter( "STATS" , sap.ui.model.FilterOperator.EQ , filterData.Status[i] ) );	
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			
			if( filters.length	>	1 || Number( filterData.Status ) > 9 ){
				this.search	=	true;
			}else{
				this.search	=	false;
			}
		}

		if (filterData.Typology && filterData.Typology.length > 0  ) {
			//	Filter on reference number
			multiFilter = [];
			for (i = 0; i < filterData.Typology.length; i++) {
				multiFilter.push( new sap.ui.model.Filter( "ATWRT" , sap.ui.model.FilterOperator.EQ , filterData.Typology[i] ) );	
			}
			filters.push(	new sap.ui.model.Filter(  multiFilter, false ) );
			if( filters.length	>	1 ){
				this.search	=	true;
			}else{
				this.search	=	false;
			}
		}
		
		
		if ( filterData.Actif || filterData.Actif === false) {
			//	Filter on reference number
			// if( this.getView().getModel("Overview").getData().Version !== "true" ){
				filters.push(new sap.ui.model.Filter("ARTTY", sap.ui.model.FilterOperator.EQ, filterData.Actif));
				
				this.search	=	true;
			// }else{
			// 	filters.push(new sap.ui.model.Filter("FICTF", sap.ui.model.FilterOperator.EQ, filterData.Actif));
			// }
		}

		return filters;
	},
	removeFilter: function( event ){
		var id = event.getSource().getId().split("-");
		this.getView().getModel("QuickFilter").setProperty( "/" + id[ id.length - 1 ] , "" );
		this.handleSearch();
	},
	handleSearch: function() {
		this.search				=	false;
		var filters 			=	this._buildFilters(),
			version				=	this.getView().getModel("Overview").getData().Version,
			treeTable   		=	this.byId("Table"),
			table				=	this.byId("GTable"),
			binding				=	table.getBinding("rows"),
			expandbutton		=	this.byId( "expandButton" );
			// oProductNameColumn	= this.byId( "Article" );
		if( version === "true" ){
			table.setVisible( false );
			treeTable.setVisible( true );
			expandbutton.setVisible( true );
		}else{
			table.setVisible( true );
			treeTable.setVisible( false );
			expandbutton.setVisible( false );
		}
		
		
		if ( version === "true") {
			// binding = treeTable.getBinding("rows");
			this.callServer( filters );
		} else {
			if( filters.length > 0 && this.search ){
				binding.filter(new sap.ui.model.Filter(filters, true));
				this.byId( "addCritere" ).setVisible( false );
			}else if( filters.length > 0 && !this.search ){
				this.byId( "addCritere" ).setVisible( true );
			}else{
				binding.filter( null ) ;
				this.byId( "addCritere" ).setVisible( false );
			}
		}
			// binding.sort(oProductNameColumn, sap.ui.table.SortOrder.Descending );
		// } else {
		// 	binding.filter(null);
		// 	// binding.sort(oProductNameColumn, sap.ui.table.SortOrder.Descending );
		// }
	},
	callServer:function( filters ){
		var service = this.getView().getModel("CatMatService"),
		thisOverview = this;
		filters.push( new sap.ui.model.Filter("SRCVS",sap.ui.model.FilterOperator.EQ,true) );
		this.getView().setBusy(true);
		service.read("/ArticleSet()", {
			filters: [new sap.ui.model.Filter(filters, true)],
			success: function(oData) {
				thisOverview.getView().getModel("articleTable").setData(thisOverview.treeModel(oData.results));
				thisOverview.getView().getModel("articleTable").setSizeLimit( oData.results.length + 100 );

				thisOverview.getView().setBusy(false);
				thisOverview.byId( "Table" ).getBinding( "rows" ).sort( [ new sap.ui.model.Sorter("ERSDA", sap.ui.table.SortOrder.Descending ) ] );

			},
			error: function(error) {
				thisOverview.getView().setBusy(false);
			}
			});
	},
	variante:function( event ){
		var oButton = event.getSource();

		// create action sheet only once
		if (!this._actionSheet) {
			this._actionSheet = sap.ui.xmlfragment(
				"CatalogMat.Fragment.VarianteActionSheet",
				this
			);
			this.getView().addDependent(this._actionSheet);
		}

		this._actionSheet.openBy(oButton);
		this._varianteType	=	this.byId( "varianteType" );
		
	},
	varianteFilter:function( event ){
		var model	=	this.getView().getModel("QuickFilter"),
			source	=	event.getSource().getId(),
			oBundle 		= this.getView().getModel( "i18n" ).getResourceBundle();
		// if( this.getView().getModel("Overview").getData().Version !== "true" ){
			if( source.includes( "Real" ) ){
				model.setProperty( "/Actif", "R" );
				this._varianteType.setText( "( " + oBundle.getText( "REAL" ) + " )" );
			}else if( source.includes( "Fictif" ) ){
				model.setProperty( "/Actif", "F" );
				this._varianteType.setText( "( " + oBundle.getText( "FICTIF" ) + " )" );
			}else{
				model.setProperty( "/Actif", "" );
				this._varianteType.setText( "" );
			}
		// }else{
		// 	if( source.includes( "Real" ) ){
		// 		model.setProperty( "/Actif", false );
		// 	}else if( source.includes( "Fictif" ) ){
		// 		model.setProperty( "/Actif", true );
		// 	}else{
		// 		model.setProperty( "/Actif", "" );
		// 	}	
		// }
		this.handleSearch();
	},
		
	selectAll: function( event, filter, search ){
		var id,
			fieldName	=	"";
		if( event ){
			id	=	event.getSource().getId();
		}else{
			id	=	filter;
		}
		if( id.includes( "Family" ) ){
			fieldName	=	"FamilyList";
		}
		if( id.includes( "Typology" ) ){
			fieldName	=	"TypologyList";
		}
		if( id.includes( "Status" ) ){
			fieldName	=	"StatusList";
		}
		if( id.includes( "Distributeur" ) ){
			fieldName	=	"DistributeurList";
		}
		if( id.includes( "Temperature" ) ){
			fieldName	=	"TemperatureList";
		}
		var field		=	this.getView().byId( fieldName ),
			list		=	field.getItems(),
			items		=	[];
			
		jQuery.each( list , function( key, value ) {
			items.push( value.getKey() );
		});
		field.setSelectedKeys( items );
		if( !search || search === undefined ){
			this.handleSearch();
		}
		this.checkAllSelected( event, filter );
	},
	
	checkAllSelected: function( event, filter ){
		var id,
			fieldName	=	"",
			iconId;
		if( event ){
			id	=	event.getSource().getId();
		}else{
			id	=	filter;
		}
		
		if( id.includes( "Family" ) ){
			fieldName	=	"FamilyList";
			iconId		=	"FamilyLi";
		}
		if( id.includes( "Typology" ) ){
			fieldName	=	"TypologyList";
			iconId		=	"TypologyLi";
		}
		if( id.includes( "Status" ) ){
			fieldName	=	"StatusList";
			iconId		=	"StatusLi";
		}
		if( id.includes( "Distributeur" ) ){
			fieldName	=	"DistributeurList";
			iconId		=	"DistributeurLi";
		}
		if( id.includes( "Temperature" ) ){
			fieldName	=	"TemperatureList";
			iconId		=	"TemperatureLi";
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
		this.handleSearch();
	}
});