<mvc:View 	xmlns:mvc		=	"sap.ui.core.mvc"
			xmlns 			=	"sap.m"
			xmlns:uxap 		=	"sap.uxap"
			xmlns:v			=	"sap.ui.comp.variants"
			xmlns:c 		=	"sap.ui.core"
			xmlns:t 		=	"sap.ui.table"
			xmlns:layout 	= 	"sap.ui.layout"
			xmlns:fb 		= 	"sap.ui.comp.filterbar"
			xmlns:var 		=	"sap.ui.comp.variants"
			controllerName 	= 	"CatalogMat.Controller.Overview" 
			height 			=	"100%">
			
	<Page 		enableScrolling	=	"false" 
				title 			=	"{i18n>APP_TITLE}" 
				class 			=	"sapMSampleFioriListReportPageOverflow">
		<Panel 	expanded 		=	"true"
				expandable		=	"false">
			<FlexBox  class 		=	"sapUiTinyMarginTop">
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiTinyMarginBegin">					
						<Label 			text 				=	"{i18n>ARTICLE}"/>
						<SearchField 	liveChange 			=	"handleSearch"
										class 				=	"sapUiTinyMarginEnd sapUiNoMarginTop"
										showSearchButton	=	"false"
										width 				=	"85%"
										value 				=	"{QuickFilter>/Article}"/>
					</FlexBox>
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiTinyMarginBegin">					
						<Label 			text 				=	"{i18n>DESIGNATION}"/>
						<SearchField 	liveChange 			=	"handleSearch"
										class 				=	"sapUiTinyMarginEnd sapUiNoMarginTop"
										showSearchButton	=	"false"
										width 				=	"85%"
										value 				=	"{QuickFilter>/Designation}"/>
					</FlexBox>
				
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiNoMarginBegin">
						<Label 			text 				=	"{i18n>MANUFACTURER}"/>
						
						<!--<Select items				=	"{VHService>/VHFournisseursSet/}"-->
						<!--		class				=	"sapUiTinyMarginEnd" -->
						<!--		width				=	"85%" -->
						<!--		forceSelection		=	"false" -->
						<!--		selectedKey 		=	"{QuickFilter>/Manufacturer}"-->
						<!--		change				=	"handleSearch">-->
						<!--	<c:Item 	key 		=	"{VHService>MFRNR}"-->
						<!--				text 		= 	"{VHService>MFRNM}"/>-->
						<!--</Select>-->
						<SearchField 	liveChange 			=	"handleSearch"
										class 				=	"sapUiTinyMarginEnd sapUiNoMarginTop"
										showSearchButton	=	"false"
										width 				=	"85%"
										value 				=	"{QuickFilter>/Manufacturer}"/>
					</FlexBox>
					
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiNoMarginBegin">
						<HBox	alignItems	=	"Start"
								width		=	"110px"
								justifyContent	=	"SpaceBetween">
							<Label	text				=	"{i18n>FAMILY}"/>
							<HBox>
								<c:Icon		src				=	"sap-icon://multiselect-all"
											size			=	"0.8rem"
											id				=	"FamilyLi"
											press			=	"selectAll"
											class			=	"sapUiTinyMarginEnd"/>
								
								<c:Icon		src				=	"sap-icon://clear-filter"
											color			=	"Red"
											size			=	"0.8rem"
											visible			=	"{	path: 'QuickFilter>/Family',
																		formatter:'CatalogMat.util.Formatter.filterLabel'}"
											id				=	"Family"
											press			=	"removeFilter"
											class			=	"sapUiTinyMarginBegin"/>
							</HBox>
						</HBox>
						<MultiComboBox	id					=	"FamilyList"
										items				=	"{VhFamily>/}"
						 				selectedKeys 		=	"{QuickFilter>/Family}"
										selectionFinish		=	"handleSearch"
										width 				=	"110px"
										selectionChange		=	"checkAllSelected">
							<c:Item 	key			 		=	"{VhFamily>KSCHL}"
										text 				= 	"{VhFamily>KSCHL}"/>
						</MultiComboBox>
						
					</FlexBox>
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiNoMarginBegin">
						<HBox	alignItems	=	"Start"
								width		=	"110px"
								justifyContent	=	"SpaceBetween">
							<Label	text				=	"{i18n>TYPOLOGY}"/>
							<HBox>
								<c:Icon		src				=	"sap-icon://multiselect-all"
											size			=	"0.8rem"
											id				=	"TypologyLi"
											press			=	"selectAll"
											class			=	"sapUiTinyMarginEnd"/>
								
								<c:Icon		src				=	"sap-icon://clear-filter"
											color			=	"Red"
											size			=	"0.8rem"
											visible			=	"{	path: 'QuickFilter>/Typology',
																		formatter:'CatalogMat.util.Formatter.filterLabel'}"
											id				=	"Typology"
											press			=	"removeFilter"
											class			=	"sapUiTinyMarginBegin"/>
							</HBox>
						</HBox>
						<MultiComboBox	id					=	"TypologyList"
										items				=	"{VhTypology>/}"
						 				selectedKeys 		=	"{QuickFilter>/Typology}"
										selectionFinish		=	"handleSearch"
										width 				=	"110px"
										selectionChange		=	"checkAllSelected">
							<c:Item 	key			 		=	"{VhTypology>ATWRT}"
										text 				= 	"{VhTypology>ATWTB}"/>
						</MultiComboBox>
						
					</FlexBox>
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiNoMarginBegin">
						<HBox	alignItems	=	"Start"
								width		=	"110px"
								justifyContent	=	"SpaceBetween">
							<Label	text				=	"{i18n>STATUS}"/>
							<HBox>
								<c:Icon		src				=	"sap-icon://multiselect-all"
											size			=	"0.8rem"
											id				=	"StatusLi"
											press			=	"selectAll"
											class			=	"sapUiTinyMarginEnd"/>
								
								<c:Icon		src				=	"sap-icon://clear-filter"
											color			=	"Red"
											size			=	"0.8rem"
											visible			=	"{	path: 'QuickFilter>/Status',
																		formatter:'CatalogMat.util.Formatter.filterLabel'}"
											id				=	"Status"
											press			=	"removeFilter"
											class			=	"sapUiTinyMarginBegin"/>
							</HBox>
						</HBox>
						<MultiComboBox	id					=	"StatusList"
										items				=	"{VhStatut>/}"
						 				selectedKeys 		=	"{QuickFilter>/Status}"
										selectionFinish		=	"handleSearch"
										width 				=	"110px"
										selectionChange		=	"checkAllSelected">
							<c:Item 	key			 		=	"{VhStatut>STATS}"
										text 				= 	"{VhStatut>VTEXT}"/>
						</MultiComboBox>
						
					</FlexBox>
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiNoMarginBegin">
						<HBox	alignItems	=	"Start"
								width		=	"110px"
								justifyContent	=	"SpaceBetween">
							<Label	text				=	"{i18n>DISTRIBUTOR}"/>
							<HBox>
								<c:Icon		src				=	"sap-icon://multiselect-all"
											size			=	"0.8rem"
											id				=	"DistributeurLi"
											press			=	"selectAll"
											class			=	"sapUiTinyMarginEnd"/>
								
								<c:Icon		src				=	"sap-icon://clear-filter"
											color			=	"Red"
											size			=	"0.8rem"
											visible			=	"{	path: 'QuickFilter>/Distributeur',
																		formatter:'CatalogMat.util.Formatter.filterLabel'}"
											id				=	"Distributeur"
											press			=	"removeFilter"
											class			=	"sapUiTinyMarginBegin"/>
							</HBox>
						</HBox>
						<MultiComboBox	id					=	"DistributeurList"
						 				selectedKeys 		=	"{QuickFilter>/Distributeur}"
										selectionFinish		=	"handleSearch"
										width 				=	"110px"
										selectionChange		=	"checkAllSelected">
							<items>
								<c:Item key		=	"L" 
										text	=	"{i18n>DIRECT}" />
								<c:Item key		=	"P" 
										text	=	"{i18n>PLATEFORME}" />
							</items>
						</MultiComboBox>
						
					</FlexBox>
					<FlexBox	direction	=	"Column"
								width 		= 	"90%"
								class 		=	"sapUiNoMarginBegin">
						<HBox	alignItems	=	"Start"
								width		=	"110px"
								justifyContent	=	"SpaceBetween">
							<Label	text				=	"{i18n>TEMPERA}"/>
							<HBox>
								<c:Icon		src				=	"sap-icon://multiselect-all"
											size			=	"0.8rem"
											id				=	"TemperatureLi"
											press			=	"selectAll"
											class			=	"sapUiTinyMarginEnd"/>
								
								<c:Icon		src				=	"sap-icon://clear-filter"
											color			=	"Red"
											size			=	"0.8rem"
											visible			=	"{	path: 'QuickFilter>/Temperature',
																		formatter:'CatalogMat.util.Formatter.filterLabel'}"
											id				=	"Temperature"
											press			=	"removeFilter"
											class			=	"sapUiTinyMarginBegin"/>
							</HBox>
						</HBox>
						<MultiComboBox	id					=	"TemperatureList"
										items				=	"{VhTemperature>/}"
						 				selectedKeys 		=	"{QuickFilter>/Temperature}"
										selectionFinish		=	"handleSearch"
										width 				=	"110px"
										selectionChange		=	"checkAllSelected">
							<c:Item 	key			 		=	"{VhTemperature>TEMPB}"
										text 				= 	"{VhTemperature>TBTXT}"/>
						</MultiComboBox>
						
					</FlexBox>
					<!--<FlexBox	width = "90%"-->
					<!--			direction	=	"Column"-->
					<!--			class =	"sapUiNoMarginBegin">-->
					<!--	<Label 			text 	=	"{i18n>WITH_PRICE}"/>-->
					<!--	<CheckBox	selected	=	"{QuickFilter>/GTPRC}"-->
					<!--				select		=	"handleSearch"/>-->
					<!--</FlexBox>-->
					<FlexBox	width = "90%"
								direction	=	"Column"
								class =	"sapUiNoMarginBegin">
						<Label 			text 	=	"{i18n>VERSION_SOURCING}"/>
						<SegmentedButton 	selectedKey	=	"{Overview>/Version}"
											class 		=	"sapUiTinyMarginEnd sapUiTinyMarginBegin"
											select		=	"onVersionClick">
							<items>
								<SegmentedButtonItem text="{i18n>NO}" key="false" />
								<SegmentedButtonItem text="{i18n>YES}" key="true"/>
							</items>
						</SegmentedButton>
					</FlexBox>
					<FlexBox	width = "30%"
								direction	=	"Column"
								class =	"sapUiNoMarginBegin">
						<Label 		text 	=	""/>
						<Button 	id 		=	"clearFilter"
									class 	=	"sapUiTinyMarginEnd sapUiNoMarginTop sapUiTinyMarginBegin"
									icon	=	"sap-icon://clear-filter"
									type	=	"Reject"
									press	=	"onClearFilter"/>
					</FlexBox>
				</FlexBox>
			</Panel>
		
			<Toolbar>
					<Label 		text   	=	"{i18n>PRODUCTS}"
								design 	=	"Bold"
								class 	=	"sapUiTinyMarginBegin"/>
					<c:Icon 	src		=	"sap-icon://navigation-down-arrow"
								press	=	"variante"/>
					<Text		id		=	"varianteType"/>
								
					<ToolbarSpacer/>
					
					<ObjectStatus	text	=	"{i18n>ADD_CRITERE}"
									id		=	"addCritere"
									visible	=	"false"
									state	=	"Error"/>
					
					<ToolbarSpacer/>
					<Button 	text 	=	"{i18n>EXPAND}"
								id		=	"expandButton"
								press 	=	"onExpandFirstLevel"
								icon 	=	"sap-icon://expand"
								type	=	"Transparent"
								class 	=	"sapUiTinyMarginEnd"
								visible =	"false"/>
					<Button 	text 	=	"{i18n>COLLAPSE}"
								id		=	"collapseButton"
								press 	=	"onCollapseAll"
								type	=	"Transparent"
								icon 	=	"sap-icon://collapse"
								class 	=	"sapUiTinyMarginEnd"
								visible =	"false"/>
					<ToolbarSeparator/>
					<Button 	text 	=	"{i18n>NEW_PRODUCT}"
								press 	=	"NewProductPress"
								icon 	=	"sap-icon://add"
								type	=	"Transparent"
								visible	=	"{Edit>/Create}"
								class 	=	"sapUiSmallMarginEnd"/>
		
				</Toolbar>	
		<t:Table	id						=	"GTable"
					rows 					=	"{CatMatService>/ArticleSet/}"
					selectionMode			=	"None"  
					enableColumnReordering	=	"true"   
					editable				=	"false" 
					enableCellFilter 		=	"true"
					selectionBehavior 		= 	"RowOnly"
					minAutoRowCount			=	"3"
					visibleRowCount 		=	"{OverviewScreenModel>/Screen}"
					showNoData 				=	"true"
					noData					=	"{i18n>NO_DATA}"
					enableBusyIndicator 	=	"true"
					threshold				=	"9999999">
			<!--<t:toolbar>	-->
			<!--	<Toolbar>-->
			<!--		<Label 		text   	=	"{i18n>PRODUCTS}"-->
			<!--					design 	=	"Bold"-->
			<!--					class 	=	"sapUiTinyMarginBegin"/>-->
			<!--		<c:Icon 	src		=	"sap-icon://navigation-down-arrow"-->
			<!--					press	=	"variante"/>-->
					
			<!--		<ToolbarSpacer/>-->
			<!--		<ToolbarSeparator/>-->
			<!--		<Button 	text 	=	"{i18n>NEW_PRODUCT}"-->
			<!--					press 	=	"NewProductPress"-->
			<!--					icon 	=	"sap-icon://add"-->
			<!--					type	=	"Default"-->
			<!--					class 	=	"sapUiSmallMarginEnd"/>-->
		
			<!--	</Toolbar>	-->
			<!--</t:toolbar>-->
			<t:columns>
				
				<t:Column  width	=	"8%">
					<Label 			text 				=	"{i18n>ARTICLE}" />
					<t:template>
						<Link 		text				= 	"{CatMatService>MATNR}" 
									emphasized 			= 	"true"
									press 				= 	"onPressArticle" />
					</t:template>
				</t:Column>
					
				<t:Column>
					<Label 			text 				=	"{i18n>DESIGNATION}"/>
					<t:template>
						<Text 		text				=	"{CatMatService>MAKTX}"/>					
					</t:template>
				</t:Column>

				<t:Column>
					<Label 			text 				=	"{i18n>MANUFACTURER}"/>
					<t:template>
						<Text 		text 				=	"{CatMatService>MFRNM}" 
									tooltip				=	"{CatMatService>MFRNM}" />
					</t:template>
				</t:Column>

				<t:Column width 		=	"8%">
					<Label 			text 				=	"{i18n>DISTRIBUTOR}"/>
					<t:template>
						<Text 		text 				=	"{CatMatService>DISTT}" />
					</t:template>
				</t:Column>

				<t:Column width 		=	"7%">
					<Label 			text 				=	"{i18n>TEMPERATURE}"/>
					<t:template>
						<Text 		text 				=	"{CatMatService>TBTXT}" />
					</t:template>
				</t:Column>						

				<t:Column width 		=	"6%">
					<Label 			text 				=	"{i18n>NET_WEIGHT}"/>
					<t:template>
						<Text 		text 				=	"{CatMatService>NTGEW}" />
					</t:template>
				</t:Column>

				<t:Column width 		=	"7.5%">
					<Label 			text 				=	"{i18n>NBR_VL}"/>
					<t:template>
						<Text 		text 				=	"{	path: 'CatMatService>VLCRN',
																	formatter:'CatalogMat.util.Formatter.returnInt'}" />
					</t:template>
				</t:Column>
				<t:Column 			width 				=	"8%"
									hAlign 				=	"Center">
					<Label 			text 				=	"{i18n>DECONDITIONED}"/>
					<t:template>
						<!--<CheckBox 	selected 			=	"{CatMatService>DCDTD}"-->
						<!--			editable			=	"false"-->
						<!--			visible 			=	"{	path: 'articleTable>isGroup',-->
						<!--										formatter:'CatalogMat.util.Formatter.isGroup'}"/>-->
						<Text 		text 					=	"{parts: [	{path: 'CatMatService>DCDTD'},
																			{path: 'CatMatService>MATNR'},
																			{path: 'CatMatService>DISTB'}],
																					formatter:'CatalogMat.util.Formatter.isDeconditionned'}"/>
						
					</t:template>
				</t:Column>
				<t:Column 			width 		=	"8%"
									hAlign 				=	"Center">
					<Label 			text 				=	"{i18n>STATUS}"/>
					<t:template>
						<Text 		text 				=	"{CatMatService>TSTAT}"/>
					</t:template>
				</t:Column>

				<t:Column	width 		=	"5%">
					<Label 			text 				=	"{i18n>PRICE}"/>
					<t:template>
						<Text 		text 				=	"{CatMatService>TARAP}" />
					</t:template>
				</t:Column>

				<t:Column	width				=	"7%"
							tooltip				=	"{i18n>UNIT_PRICE}">
					<Label 			text 				=	"{i18n>UNIT_PRICE_SHORT}"
									tooltip				=	"{i18n>UNIT_PRICE}"/>
					<t:template>
						<Text 		text 				=	"{CatMatService>MEINS}" />
					</t:template>
				</t:Column>

				<t:Column width 		=	"5%">
					<Label 			text				=	"{i18n>IMAGE}" />
					<t:template>
						<Image 		src 				=	"{	path: 'CatMatService>IMSRC',
																formatter:'CatalogMat.util.Formatter.imagePlaceHolder'}" 
									width 				=	"50px"
									height				=	"45px"
									press 				=	"onImagePreview"/>
					</t:template>
				</t:Column>

			</t:columns>					
		</t:Table>
		
		<t:TreeTable id						=	"Table"
					rows 					=	"{	path:		'articleTable>/',
			    									parameters: {arrayNames:['items']}
													}"
					selectionMode			=	"None"  
					enableColumnReordering	=	"true"   
					editable				=	"false" 
					enableCellFilter 		=	"true"
					selectionBehavior 		= 	"RowOnly"
					minAutoRowCount			=	"3"
					visibleRowCount 		=	"{OverviewScreenModel>/Screen}"
					showNoData 				=	"true"
					noData					=	"{i18n>NO_DATA}"
					enableBusyIndicator 	=	"true"
					threshold				=	"9999999"
					visible 				=	"false">
			<!--<t:toolbar>	-->
				<!--<Toolbar>-->
				<!--	<Label 		text   	=	"{i18n>PRODUCTS}"-->
				<!--				design 	=	"Bold"-->
				<!--				class 	=	"sapUiTinyMarginBegin"/>-->
				<!--	<c:Icon 	src		=	"sap-icon://navigation-down-arrow"-->
				<!--				press	=	"variante"/>-->
								
				<!--	<ToolbarSpacer/>-->
				<!--	<Button 	text 	=	"{i18n>EXPAND}"-->
				<!--				id		=	"expandButton"-->
				<!--				press 	=	"onExpandFirstLevel"-->
				<!--				icon 	=	"sap-icon://expand"-->
				<!--				class 	=	"sapUiTinyMarginEnd"-->
				<!--				visible =	"true"/>-->
				<!--	<Button 	text 	=	"{i18n>COLLAPSE}"-->
				<!--				id		=	"collapseButton"-->
				<!--				press 	=	"onCollapseAll"-->
				<!--				icon 	=	"sap-icon://collapse"-->
				<!--				class 	=	"sapUiTinyMarginEnd"-->
				<!--				visible =	"false"/>-->
				<!--	<ToolbarSeparator/>-->
				<!--	<Button 	text 	=	"{i18n>NEW_PRODUCT}"-->
				<!--				press 	=	"NewProductPress"-->
				<!--				icon 	=	"sap-icon://add"-->
				<!--				type	=	"Default"-->
				<!--				class 	=	"sapUiSmallMarginEnd"/>-->
		
				<!--</Toolbar>	-->
			<!--</t:toolbar>-->
			<t:columns>
				
				<t:Column width	=	"10%">
					<Label 			text 				=	"{i18n>ARTICLE_NUMBER}" 
									id					=	"Article"/>
					<t:template>
						<Link 		text				= 	"{articleTable>MATNR}" 
									emphasized 			= 	"true"
									press 				= 	"onPressArticle" />
					</t:template>
				</t:Column>
					
				<t:Column>
					<Label 			text 				=	"{i18n>DESIGNATION}"/>
					<t:template>
						<Text 		text				=	"{articleTable>MAKTX}"/>					
					</t:template>
				</t:Column>

				
				<t:Column>
					<Label 			text 				=	"{i18n>MANUFACTURER}"/>
					<t:template>
						<Text 		text 				=	"{articleTable>MFRNM}" 
									tooltip				=	"{articleTable>MFRNM}" />
					</t:template>
				</t:Column>
				
				<t:Column width 		=	"8%">
					<Label 			text 				=	"{i18n>DISTRIBUTOR}"/>
					<t:template>
						<Text 		text 				=	"{articleTable>DISTT}" />
					</t:template>
				</t:Column>

				<t:Column width 		=	"7%">
					<Label 			text 				=	"{i18n>TEMPERATURE}"/>
					<t:template>
						<Text 		text 				=	"{articleTable>TBTXT}" />
					</t:template>
				</t:Column>						

				<t:Column width 		=	"5.5%">
					<Label 			text 				=	"{i18n>NET_WEIGHT}"/>
					<t:template>
						<Text 		text 				=	"{articleTable>NTGEW}" />
					</t:template>
				</t:Column>

				<t:Column width 		=	"7.5%">
					<Label 			text 				=	"{i18n>NBR_VL}"/>
					<t:template>
						<Text 		text 				=	"{	path: 'articleTable>VLCRN',
																	formatter:'CatalogMat.util.Formatter.returnInt'}" />
					</t:template>
				</t:Column>
				<t:Column 			width 				=	"8%"
									hAlign 				=	"Center">
					<Label 			text 				=	"{i18n>DECONDITIONED}"/>
					<t:template>
						<!--<CheckBox 	selected 			=	"{articleTable>DCDTD}"-->
						<!--			editable			=	"false"-->
						<!--			visible 			=	"{	path: 'articleTable>isGroup',-->
						<!--										formatter:'CatalogMat.util.Formatter.isGroup'}"/>-->
						<Text 		text 					=	"{parts: [	{path: 'articleTable>DCDTD'},
																			{path: 'articleTable>MATNR'},
																			{path: 'articleTable>DISTB'}],
																					formatter:'CatalogMat.util.Formatter.isDeconditionned'}"/>
						<!--visible 				=	"{parts: [	{path: 'articleTable>isGroup'},-->
						<!--													{path: 'articleTable>/ISPRT'}],-->
						<!--															formatter:'CatalogMat.util.Formatter.isGroup'}"-->
						
					</t:template>
				</t:Column>
				<t:Column 			width 		=	"8%"
									hAlign 				=	"Center">
					<Label 			text 				=	"{i18n>STATUS}"/>
					<t:template>
						<Text 		text 				=	"{articleTable>TSTAT}"/>
						
					</t:template>
				</t:Column>

				<t:Column width 		=	"5%">
					<Label 			text 				=	"{i18n>PRICE}"/>
					<t:template>
						<Text 		text 				=	"{articleTable>TARAP}" />
					</t:template>
				</t:Column>

				<t:Column  width 		=	"7%">
					<Label 			text 				=	"{i18n>UNIT_PRICE}"/>
					<t:template>
						<Text 		text 				=	"{articleTable>MEINS}" />
					</t:template>
				</t:Column>

				<t:Column width 		=	"5%">
					<Label 			text				=	"{i18n>IMAGE}" />
					<t:template>
						<Image 		src 				=	"{	path: 'articleTable>IMSRC',
																formatter:'CatalogMat.util.Formatter.imagePlaceHolder'}" 
									width 				=	"50px"  
									height				=	"45px"
									press 				=	"onImagePreview"/>
					</t:template>
				</t:Column>

			</t:columns>					
		</t:TreeTable>		
	</Page>
</mvc:View>