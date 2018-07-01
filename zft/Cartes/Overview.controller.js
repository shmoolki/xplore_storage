jQuery.sap.require( "sap/ui/model/Filter" );
jQuery.sap.require( "sap/ui/model/FilterOperator" );
jQuery.sap.require(	"CatalogCartes/util/Formatter" );

sap.ui.controller(  "CatalogCartes.controller.Overview", {
	/**
	* Called when a controller is instantiated and its View controls (if available) are already created.
	* Can be used to modify the View before it is displayed, to bind event handlers and do other one-time initialization.
	* @memberOf test.detail
	*/
	thisOverview:null,
	flag	:	false,
	onInit: function() {
		this.getView().addStyleClass( "sapUiSizeCompact" );
		//	Routing
		this.router 	= sap.ui.core.UIComponent.getRouterFor(this);
		this.router.attachRoutePatternMatched( this.handleRouting , this);
	
		//	Model initialization
		this.InitModels();
		
		// this.byId("RecetteInput").setFilterFunction(function(sTerm, oItem) {
		// 	// A case-insensitive 'string contains' style filter
		// 	return oItem.getText().match(new RegExp(sTerm, "i"));
		// });
		
	},
	/**
	 * Models initialization
	 */
	InitModels: function(){
		// Filter model
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "QuickFilter" );
		
		// Model du nombre de ligne de la table principal en fonction de la taille de l'ecran
		this.getView().setModel( new sap.ui.model.json.JSONModel({
																	Screen		:	17
																	}), "OverviewScreenModel" );
		
																
		// Defini le nombre de ligne dans la principal
		this._screenSize();
		
		// Initialisation des model de liste
		this.VHModelsInit();
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
	
	/**
	 * Convenience method for getting the resource bundle.
	 * @public
	 * @returns {sap.ui.model.resource.ResourceModel} the resourceModel of the component
	 */
	getResourceBundle: function() {
		return this.getOwnerComponent().getModel("i18n").getResourceBundle();
	},
	

	/**
	 * fonction a lancer pendant la naviagtion
	 */
	handleRouting: function( event ){
		// Si on navigue vers l'overview on fait un rafraichissement de la table
		if( event.getParameter( "name" ) === "Overview" ){
			this.handleSearch();
		}

	},
	
	/**
	 * Recuperation de la liste des statuts 
	 * initialisation des valeur pre-filtrer
	 */
	VHModelsInit: function(){
		var service 		= 	this.getOwnerComponent().getModel( "CarteService" ),
			that 			=	this;
		
		this.getView().setModel( new sap.ui.model.json.JSONModel(), "VHCAStatusSet" );
		// recuperation des statuts
		service.read( "/VHCAStatusSet",{    
			success: function( oData ) {
		        // remplis la liste de tout les valeur des statuts
		        that.getView().getModel( "VHCAStatusSet" ).setData( oData.results );
		        var field		=	that.getView().byId( "StatusList" ),
					list		=	field.getItems(),
					items		=	[];
		        
		        // cree une liste des valeurs a pre-filtrer
				jQuery.each( list , function( key, value ) {
					if( value.getKey() !== "40" ){
						items.push( value.getKey() );
					}
				});
				// selectionne les valeurs a pre-filtrer
				field.setSelectedKeys( items );
				// lance la recherche avec les nouvelles valeur selectionné
				that.handleSearch();
				// UI:	Verifie si toute les valeurs sont rempli ou non
				//		affiche l'icone correspondant
				that.checkAllSelected( false, "StatusList" );
		        
		    },
		    error: function( error ) {
		    }
    	});
    	//	Defini le filtre de date au jour du lancement de l'application jusqu'au 31.12.2999
    	var filter	=	this.getView().getModel( "QuickFilter" ).getData(),
			date	=	new Date(),
			day		=	date.getUTCDate() + "",
			month	=	date.getMonth() + 1 + "";
		if( day.length === 1 ){
			day	=	"0" + day;
		}
		if( month.length === 1 ){
			month	=	"0" + month;
		}
		filter.DateValide	=	day + "." + month + "." + date.getUTCFullYear() + " - 31.12.2999";
		this.byId( "dateRange" ).setValue( filter.DateValide );
    	
	},

	/**
	 * Fonction qui selectionne toute les valeurs d'une liste
	 * au clic sur l'icone de 'tout selectionner'
	 */
	selectAll: function( event ){
		var id			=	event.getSource().getId(),
			fieldName	=	"";
		// Verifie sur qu'elle liste tout selectionner
		if( id.includes( "Hierarchy" ) ){
			fieldName	=	"HierarchyList";
		}
		if( id.includes( "Status" ) ){
			fieldName	=	"StatusList";
		}
		var field		=	this.getView().byId( fieldName ),
			list		=	field.getItems(),
			items		=	[];
		// rempli un model temporaire avec toute les valeurs de la liste
		jQuery.each( list , function( key, value ) {
			items.push( value.getKey() );
		});
		// selectionne les valeurs de la liste avec les valeurs du model
		field.setSelectedKeys( items );
		// lance la recherche pour les nouvelles valeurs
		this.handleSearch();
		// verifie si toute les vsleurs de le liste sont selectionner 
		// et affiche les icones correspondant
		this.checkAllSelected( event );
	},
	
	/**
	 * Fonction qui vérifie si toutes les lignes de la liste est selectionner
	 * Affiche/masque les icones correspondant
	 */
	checkAllSelected: function( event ,fieldId ){
		var id,
			fieldName	=	"",
			iconId;
		// Recuperation de la liste a vérfier
		// Si viens d'une fonction le fieldId est rempli
		// Si viens part evenement on recupere l'id de la liste
		if( !event ){
			id			=	fieldId;	
		}else{
			id			=	event.getSource().getId();
		}
		if( id.includes( "Hierarchy" ) ){
			fieldName	=	"HierarchyList";
			iconId		=	"HierarchyLi";
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
	
	/**
	 * Decoche toute les lignes de la liste au click sur icone de suppression
	 */
	removeFilter: function( event ){
		var id = event.getSource().getId().split("-");
		this.getView().getModel("QuickFilter").setProperty( "/" + id[ id.length - 1 ] , "" );
		this.checkAllSelected( event );
		this.handleSearch();
	},
	
	
	/**
	 *	Reset all filters 
	 */
	onClearFilter: function(){
		this.getView().getModel( "QuickFilter" ).setData({});
		this.byId( "StatusLi" ).setVisible( true );
		this.byId( "HierarchyLi" ).setVisible( true );
		this.handleSearch();
	},
	/**
	 * Initialistion of newproduct popUp
	 */
	NewCartePress: function(){
		//Routing
		this.navigationTo( "NouvelleCarte", null, false );
	},
	
	/**
	 * Carte duplication
	 */
	DuplicateCarte:function( event ){
		var table	=	this.byId("Table"),
			path	=	table.getSelectedIndex(),
			ctnum	=	table.getContextByIndex(path).getPath().split("'")[1],
			that	=	this,
			service	=	this.getView().getModel( "CarteService" );
		// fonction de chargement de données de la carte a dupliquer 
		// Pour recuperer la liste des SR a reprendre
		that.readCarte(service, ctnum, that);
	},
	
	
	/**
	 * Fonction de chargement de données de la carte a dupliquer 
	 * Affiche une popUp avec la liste des SR
	 */
	readCarte: function( service, ctnum, that ){
		var oBundle = 	this.getView().getModel("i18n").getResourceBundle(),
			param;
		that.getView().setBusy( true );
		service.read( "/MenuSet('" + ctnum + "')" , {
			urlParameters: 	"$expand=MN2DT,MN2DM,MN2FL,MN2ST",
			success: function ( oData ) {
				// Fonction de construction de la liste des SR
				that.chooseDuplicateSR( oData.MN2DT.results, ctnum );
				that.getView().setBusy( false );
				// Affiche une popUp de confirmation si on veux recupere des SR dans la carte a dupliquer ou non
				if( that.getView().getModel( "duplicateSR" ).getData().length > 0 ){
					var dialog	= new sap.m.Dialog({
							title: oBundle.getText( "DUPLICATE" ),
							type: 'Message',
							content: new sap.m.Text({ text: oBundle.getText( "WITH_SR" ) }),
							
							beginButton: new sap.m.Button({
								icon : "sap-icon://accept",
								type: "Accept",
								press: function () {
									// Ouvre la liste des SR de la carte a dupliquer
									that.openSrList( ctnum );
									dialog.close();
								}
							}),
							
							endButton: new sap.m.Button({
								icon : "sap-icon://decline",
								type: "Reject",
								press: function () {
									ctnum = ctnum + "$0";
									dialog.close();
									param	=	{	"Carte":ctnum	};
									that.navigationTo( "DupliquerCarte", param, false );
								}
							}),
							afterClose: function () {
								dialog.destroy();
							}
						});
					dialog.open();
				}else{
					ctnum = ctnum + "$0";
					param	=	{	"Carte":ctnum	};
					that.navigationTo( "DupliquerCarte", param, false );
				}
			},
			error: function( e ){
				that.getView().setBusy( false );
			}
		});
	},
	
	
	/**
	 * Construit la liste des SR
	 */
	chooseDuplicateSR:function( model, ctnum ){
		var srList	=	[];
		
		for (var i=0; i<model.length; i++) {
			if( model[ i ].FRNUM.includes( "SR" ) && model[ i ].RSTAT !== "D" ){
				srList.push( model[i] );
			}
		}
		this.getView().getModel( "duplicateSR" ).setData( srList );
	},
	
	
	/**
	 *	Affiche la liste des SR dans une popUp
	 */
	openSrList: function( ctnum ){
		if( !this._SRList ){
			this._SRList = sap.ui.xmlfragment( "CatalogCartes.fragment.srList", this);
			this.getView().addDependent(this._SRList);
		}
		this._SRList.getAggregation( "_dialog" ).getAggregation( "subHeader" ).setVisible(false);
	 	this._SRList.open();
	 	this._SRList.ctnum	=	ctnum;
	},
	
	
	/**
	 * Fonction de confirmation de la selection des SR a reprendre pour la duplication
	 * Passe en parametre $1 en plus du numéro de carte pour signifier qu'il y a des SR a reprendre
	 * Et enfin lance la navigation vers le detail de la création de la carte dupliqué
	 */
	confirmSrList:function( event ){
		var items	=	event.getParameter("selectedItems"),
			temp	=	[],
			model	=	this.getView().getModel( "duplicateSR" );
		items.forEach(function( item ){
			temp.push( model.getProperty( item.getBindingContext( "duplicateSR" ).getPath() ) );
		});
		model.setData( temp );
		var param	=	{	"Carte": this._SRList.ctnum + "$1"	};
		
		this.navigationTo( "DupliquerCarte", param, false );
	},
	

	
	/**
	 * routing to the article's detail view
	 */
	onPressArticle: function( event ) {
		var display	=	this.getView().getModel( "Edit" ).getProperty( "/Display" );
		if( display ){
			var articleNumber 	= event.getSource().getText(),
				//sets the parameter of the article
				param 			= {	"Carte":articleNumber	};
			
			//Routing
			this.navigationTo( "Detail", param, false );
		}
	},
	
	/**
	 * Set duplicate bouton visible on selected row
	 */
	onSelectedRow:function (){
		var nbSelected 	=	this.byId( "Table" ).getSelectedIndices().length,
			duplicate 	=	this.byId( "duplicateButton" ),
			create		=	this.getView().getModel( "Edit" ).getProperty( "/Create" );
		if( create ){
			if( nbSelected === 1 ){
				duplicate.setVisible( true );
			}else{
				duplicate.setVisible( false );
			}
		}
	},
	
	/**
	 * Open dialog popUp for image preview
	 */
	onImagePreview:function ( event ){
		var source 	=	event.getSource(),
			model	=	this.getView().getModel("CarteService"),
			path	=	source.getParent().getBindingContext("CarteService").getPath(),
			URL 	=	source.getSrc(),
			artNum	=	model.getObject(path).DESCR;

		if( !this._previewImageDialog ){
			this._previewImageDialog = sap.ui.xmlfragment( "CatalogCartes.fragment.imageDialog", this);
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
	
	/**
	 * Builder of the filters of the table
	 */
	_buildFilters: function () {
		var filterData 	= this.getView().getModel( "QuickFilter" ).getData(),
			i,
			filters 	= [];
		
		// Filtre sur la description a partir de 3 caracteres
		if( filterData.Description && filterData.Description.length > 2 ) {
			//	Filter on reference number
			filters.push(	new sap.ui.model.Filter( "DESCR" , sap.ui.model.FilterOperator.Contains , filterData.Description ) );	
		}
		
		// Filtre sur la recette a partir de 3 caracteres
		if( filterData.Recette && filterData.Recette.length > 2 ) {
			var value	=	filterData.Recette.toUpperCase();
			// Construit le filtre si le 3eme caractere est un chiffre
			// Qu'il commence par FT ou SR et qu'il contient 6 caracteres et plus
			if( !isNaN( value.charAt( 2 ) ) && 
				( value.startsWith( "FT" ) || value.startsWith( "SR" ) ) &&
				value.length > 5 ){
				filters.push(	new sap.ui.model.Filter( "FRNUM" , sap.ui.model.FilterOperator.StartsWith , filterData.Recette ) );
			// Construit filtre si il commende ni par FT ni par SR et que la valeur n'est pas un chiffre
			}else if( !value.startsWith( "FT" ) && !value.startsWith( "SR" ) && isNaN( value ) ){
				filters.push(	new sap.ui.model.Filter( "FRNUM" , sap.ui.model.FilterOperator.Contains , filterData.Recette ) );
			}
			
		}
		
		// filtre multiple sur la hierarchie
		if( filterData.Hierarchy ) {
			var multiFilterH = [];
			for (i=0; i<filterData.Hierarchy.length; i++) {
				multiFilterH.push( new sap.ui.model.Filter(  "DSHIE" , sap.ui.model.FilterOperator.EQ , filterData.Hierarchy[i] ) );
			}
			filters.push(	new sap.ui.model.Filter(  multiFilterH, false ) );
		}
		
		// Filtre multiple sur les status
		if( filterData.Status ) {
			//	Filter on reference number
			var multiFilterS = [];
			for (i=0; i<filterData.Status.length; i++) {
				multiFilterS.push( new sap.ui.model.Filter(  "STATS" , sap.ui.model.FilterOperator.EQ , filterData.Status[i] ) );
			}
			filters.push(	new sap.ui.model.Filter(  multiFilterS, false ) );	
		}
		
		// Filtre plage de date 
		if( filterData.DateValide ) {
			var deb		=	filterData.DateValide.split( " - " )[0],
				fin 	=	filterData.DateValide.split( " - " )[1],
				date	=	deb.split(".");
				
			deb 	=	date[2]	+	date[1]	+	date[0];
			date	=	fin.split( "." );
			fin 	=	date[2]	+	date[1]	+	date[0];
			//	Filter on date
			filters.push(	new sap.ui.model.Filter( "APDEB" , sap.ui.model.FilterOperator.BT , deb , fin ) );	
		}
		return filters;
	},
	
	/**
	 *	Filter liveChange of all filters of the table
	 */
	handleSearch: function(){
		var binding 	=	this.byId( "Table" ).getBinding("rows"),
			filters 	=	this._buildFilters();
			
			if( filters.length > 0 ){
				filters.push( 	new sap.ui.model.Filter( "CTNUM" , sap.ui.model.FilterOperator.NE , "" ) );
				binding.filter( new sap.ui.model.Filter( filters, true) );
			}else{
				binding.filter( null );
			}
	}
});