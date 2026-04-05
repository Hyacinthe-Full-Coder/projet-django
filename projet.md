```
UNIVERSITEDEKARA  DEPARTEMENTDEMATHEMATIQUES
```
```
FiliereDevelopp ementWebetMobile  2024/
```
```
Cours:FrameworksPython
```
## TPFINAL DE FIN DE COURS

# Application de Gestion

# des Reclamations

## MinisteredelaJusticeetdelaLegislation

```
Backend
```
## DjangoREST

```
+PostgreSQL
```
```
Frontend
```
## Flutter/Dart

```
MobileAndroid/iOS
```
```
4 Phasesdedevelopp ement
Phase 1 :Conception  Phase 2 :Backend  Phase 3 :Frontend 
Phase 4 :Integration
```
```
Comp etencesevalueesalanducours:
```
I Concevoir une API REST avec
DjangoRESTFramework

I Implementer l'authenticationJWT
(SimpleJWT)
IMo deliseretmanipuleruneBDDavec
l'ORMDjango

I Developp er une application Flutter
multiplateforme
I Consommer une API REST depuis
Flutter(http)

I Gerer les roles et p ermissions cote
DRF
IMettreenplaceunsystemedetickets
complet

```
ITesteretvalideruneintegrationFull-
Stack
```
```
Phase 1
Conception&
Architecture
```
```
Phase 2
DjangoBackend+
API
```
```
Phase 3
FlutterFrontend+UI
```
```
Phase 4
Integration&Tests
```

```
Rendudupro jetviaGitHub(push):
```
## https://github.com/lawsonlatevisena

```
fork→developp er→git push origin main
```

## Contents


- 1 ContexteetPresentationduPro jet
   - 1.1 Contextegeneral
   - 1.2 Ob jectifsdupro jet
   - 1.3 Perimetredupro jet.
      - 1.3.1 Utilisateurscibles.
      - 1.3.2 Fonctionnalitesprincipalesattendues
- 2 ArchitectureTechnique
   - 2.1 Stacktechnologiqueretenu.
   - 2.2 Architecturegeneraledusysteme
   - 2.3 Structuredespro jets
      - 2.3.1 Structuredupro jetDjango
      - 2.3.2 Structuredupro jetFlutter
- 3 Phase 1 ConceptionetMo delisation
   - 3.1 Diagrammedecasd'utilisation
   - 3.2 Diagrammedeclasses.
   - 3.3 Diagrammedesequences:Creationd'unticket
- 4 Phase 2 Developp ementBackendDjango
   - 4.1 Miseenplacedel'environnement
      - 4.1.1 Congurationsettings.py
   - 4.2 Mo delesdedonnees.
      - 4.2.1 Mo deleutilisateurp ersonnaliseaccounts/models.py
      - 4.2.2 Mo delesdesticketstickets/models.py
   - 4.3 SerializersDRF
   - 4.4 Permissionsp ersonnalisees
   - 4.5 VuesetEndp ointsAPI
   - 4.6 URLsdel'API
- 5 Phase 3 Developp ementFrontendFlutter
   - 5.1 Initialisationdupro jetFlutter.
      - 5.1.1 Dep endancespubspec.yaml.
   - 5.2 Mo delesDart
   - 5.3 Serviced'authentication.
   - 5.4 Servicedegestiondestickets.
   - 5.5 EcransFlutter.
      - 5.5.1 Ecrandeconnexionscreens/login_screen.dart
      - 5.5.2 Ecranlistedesticketsscreens/ticket_list_screen.dart
      - 5.5.3 WidgetTicketCardwidgets/ticket_card.dart
   - 5.6 Ecrandecreationd'unticket
- 6 Phase 4 Integration,TestsetValidation
   - 6.1 Scenariosdetestsavalider.
   - 6.2 Bonnespratiquesdesecurite
   - 6.3 GestiondeserreursdansFlutter.
- 7 LivrablesetCriteresd'Evaluation
   - 7.1 Livrablesattendus
   - 7.2 Grilled'evaluation
   - 7.3 Criteresdereussitedupro jet
- 8 RessourcesetAide-Memoire
   - 8.1 CommandesutilesDjango
   - 8.2 CommandesutilesFlutter
   - 8.3 Adressesutilesendevelopp ement
   - 8.4 Do cumentationocielle


## 1 ContexteetPresentationduPro jet

### 1.1 Contextegeneral

LeMinisteredelaJusticeetdelaLegislationaamorceunpro cessusdedigitalisation
desesservicesandefaciliterl'accesdescitoyensadesservicesessentiels(casierjudiciaire,
certicatdenationalite,extraitsd'actes,etc.).
Cep endant,malgrecesavanceestechnologiques,desdicultestechniques,despannes
recurrentes,ainsiquedes retoursd'insatisfaction ontetesignales, tantparlesusagers
queparlesagents internes. Ces problemes nefontactuellementl'ob jetd'aucun suivi
structure,cequientrainedesretardsdetraitementetunedegradationdelaqualitede
service.
Danscecontexte,lacelluleinformatiqueduministereprop oselamiseenplaced'une
applicationcentraliseedegestion des reclamations et desplaintes, app ortant
unevaleura jouteestrategiqueaplusieursniveaux:

I Ameliorationdela qualiteduservicerenduauxcitoyensetauxagentsparune
priseenchargerapideetstructureedesproblemessignales.

I Optimisationdutravaildel'equip etechnique,graceaunsystemed'attribution
automatisee,depriorisationetdesuividestickets.

I Renforcementdelatransparenceetdelatracabilitedesactionsentreprisessur
chaqueticketouplainte.

I Pro ductiondestatistiquesetd'indicateursables,facilitantlepilotagedusup-
p ortetl'aidealadecision.

I Archivagedesreclamationstraiteesp ourassurerunememoiretechniqueetameliorer
lagestiondespro cess.

### 1.2 Ob jectifsdupro jet

```
Ob jectifsduTP
```
```
XOrir uneplateforme centraliseep ourla gestionetle suividesreclamations et
requetes.
```
```
XAssurerlesuivietletraitementecacedesticketsviaunworkowclair.
```
```
XFaciliterl'archivage,l'analyseetlatracabilitedesreclamations.
```
```
XAmeliorerlacommunicationentrelesutilisateursetl'equip etechnique.
```
```
XDevelopp eruneapplicationmobileFlutterquiconsommel'APIDjangoREST.
```

### 1.3 Perimetredupro jet.

#### 1.3.1 Utilisateurscibles.

```
Prol Description
Citoyen/Agentmetier Soumetdesreclamations,suitl'etatdesestickets,recoit
desnotications.
Techniciensupp ort Recoit les tickets assignes, les traite, met a jour leur
statut.
Administrateur Gere les utilisateurs, lesroles, les typ esde tickets, les
statistiques.
```
#### 1.3.2 Fonctionnalitesprincipalesattendues

```
A.Coteutilisateur(citoyensetagents)
```
- Creationdeticketousoumissiondereclamation(formulaireFlutter).
- Suividel'etatduticket:Ouvert,Encours,Resolu,Clos.
- Consultationdel'historiquedesdemandes.
- Noticationsachaquechangementd'etatduticket.

```
B.Cotecelluleinformatique(supp orttechnique)
```
- Receptioncentraliseedesticketsviatableaudeb ordFlutter.
- Attributionautomatiqueoumanuelledesticketsauxtechniciens.
- Interfacedetraitementdesticketsavecsuividesactions.
- Systemedeclassement,ltrageetrecherchedestickets.
- Generationdestatistiquesettableauxdeb ord.

```
C.Administrationdelaplateforme
```
- Gestiondesutilisateursetdesroles(DjangoAdmin+API).
- Parametragedestyp esdetickets:incident,reclamation,demande.
- Congurationdesprioritesetdesdelaisdetraitement.
- Archivageautomatiquedesticketsclosapresuncertaindelai.

## 2 ArchitectureTechnique

2.1. Stacktechnologiqueretenu


```
Couche Technologie Role
BackendAPI Django4.x+DRF Gestiondesmo deles,APIREST,p ermis-
sions,JWT
Authentication SimpleJWT EmissionetvericationdestokensJWT
Basededonnees PostgreSQL Sto ckagep ersistant desticketsetutilisa-
teurs
Frontendmobile Flutter3.x(Dart) InterfacemobileAndroid/iOS
HTTPClient packagehttp(Dart) CommunicationFlutter->APIDjango
Sto ckagelo cal SharedPreferences PersistancedutokenJWTcotemobile
```
### 2.2 Architecturegeneraledusysteme

```
ApplicationFlutter APIRESTDjangoDRF
```
```
DjangoCore(Views)
```
```
ORMDjango
```
```
PostgreSQL
```
```
SimpleJWTAuth
```
```
DjangoAdmin
```
```
HTTP/JSON
```
```
Remarqueimp ortante
```
```
LefrontendFlutternecommuniquejamais directementaveclabasededonnees.
Touteinteraction passeobligatoirement parl'API REST Django. Letoken JWT
obtenulorsdelaconnexioneststo ckelo calementviaSharedPreferencesetinclus
danschaquerequeteAuthorization: Bearer <token>.
```
### 2.3 Structuredespro jets

#### 2.3.1 Structuredupro jetDjango

```
g e s t i o n _ r e c l a m a t i o n s / # R a c i n e d u p r o j e t D j a n g o
| - - m a n a g e. p y
| - - c o n f i g / # D o s s i e r d e c o n f i g u r a t i o n
| | - - _ _ i n i t _ _. p y
```

```
| | - - s e t t i n g s. p y
| | - - u r l s. p y
| | - - w s g i. p y
| - - t i c k e t s / # A p p l i c a t i o n p r i n c i p a l e
| | - - _ _ i n i t _ _. p y
| | - - m o d e l s. p y # M o d e l e s T i c k e t , C o m m e n t a i r e
| | - - s e r i a l i z e r s. p y # S e r i a l i z e r s D R F
| | - - v i e w s. p y # V i e w S e t s e t A P I V i e w s
| | - - u r l s. p y # R o u t e s A P I
| | - - p e r m i s s i o n s. p y # P e r m i s s i o n s p e r s o n n a l i s e e s
| | - - a d m i n. p y # I n t e r f a c e D j a n g o A d m i n
| - - a c c o u n t s / # A p p l i c a t i o n u t i l i s a t e u r s
| | - - _ _ i n i t _ _. p y
| | - - m o d e l s. p y # P r o f i l u t i l i s a t e u r e t e n d u
| | - - s e r i a l i z e r s. p y
| | - - v i e w s. p y # I n s c r i p t i o n , p r o f i l
| | - - u r l s. p y
| - - r e q u i r e m e n t s. t x t
```
#### 2.3.2 Structuredupro jetFlutter

```
r e c l a m a t i o n s _ a p p / # R a c i n e d u p r o j e t F l u t t e r
| - - p u b s p e c. y a m l
| - - l i b /
| | - - m a i n. d a r t # P o i n t d ' e n t r e e
| | - - m o d e l s /
| | | - - t i c k e t. d a r t # M o d e l e T i c k e t
| | | - - u s e r. d a r t # M o d e l e U t i l i s a t e u r
| | - - s e r v i c e s /
| | | - - a p i _ s e r v i c e. d a r t # C l a s s e H T T P c l i e n t
| | | - - a u t h _ s e r v i c e. d a r t # L o g i n , l o g o u t , J W T
| | | - - t i c k e t _ s e r v i c e. d a r t # C R U D t i c k e t s
| | - - p r o v i d e r s /
| | | - - a u t h _ p r o v i d e r. d a r t # E t a t d ' a u t h e n t i f i c a t i o n
| | | - - t i c k e t _ p r o v i d e r. d a r t
| | - - s c r e e n s /
| | | - - l o g i n _ s c r e e n. d a r t
| | | - - h o m e _ s c r e e n. d a r t
| | | - - t i c k e t _ l i s t _ s c r e e n. d a r t
| | | - - t i c k e t _ d e t a i l _ s c r e e n. d a r t
| | | - - c r e a t e _ t i c k e t _ s c r e e n. d a r t
| | | - - a d m i n _ d a s h b o a r d _ s c r e e n. d a r t
| | - - w i d g e t s /
| | | - - t i c k e t _ c a r d. d a r t
| | | - - s t a t u s _ b a d g e. d a r t
```

## 3 Phase 1 ConceptionetMo delisation

```
Phase 1 ConceptionetMo delisation
```
```
Avantdeco der,vousdevezpro duirelesdo cumentsdeconceptionnecessaires. Cette
phaseestobligatoireetconstitueunpre-requisp ourlesphasessuivantes.
```
### 3.1 Diagrammedecasd'utilisation

```
Identiezlesacteursetleursinteractionsaveclesysteme.
TravauxPratiques:Diagrammedecasd'utilisationUseCase
```
```
Realisezalamainouavecunoutil(draw.io,PlantUML)undiagrammeUMLdecas
d'utilisationaveclestroisacteurs(Citoyen/Agent,Technicien,Administrateur)etles
casd'utilisationsuivants:
```
- Creeruncompte/Seconnecter
- Soumettreunticket
- Consultersestickets
- Suivrel'etatd'unticket
- Commenterunticket
- Voirlesticketsassignes
    - Changerlestatutd'unticket
    - Assignerunticket
    - Gererlesutilisateurs
    - Voirlesstatistiques
    - Archiverlesticketsclos
    - Congurerlestyp esetpriorites

### 3.2 Diagrammedeclasses.


```
TravauxPratiques:Diagrammedeclasses
```
```
ConcevezlediagrammedeclassesUMLdusysteme.Atitreindicatif,voicilesentites
minimalesattendues:
```
```
I User(heritedeAbstractUserDjango): id,email,role(CITOYEN,TECHNI-
CIEN,ADMIN),telephone.
```
```
I Ticket : id, titre, description, type_ticket (INCIDENT, RECLAMA-
TION, DEMANDE), statut (OUVERT, EN_COURS, RESOLU, CLOS),
priorite (BASSE, NORMALE, HAUTE, CRITIQUE), date_creation,
date_modification, date_resolution, auteur (FK User), assigne_a (FK
User, nullable).
```
```
I Commentaire:id,contenu,date,ticket (FK Ticket),auteur (FK User).
```
```
I HistoriqueStatut : id, ancien_statut, nouveau_statut, date_changement,
ticket (FK Ticket),modifie_par (FK User).
```
### 3.3 Diagrammedesequences:Creationd'unticket

```
TravauxPratiques:Diagrammedesequences
```
```
RealisezlediagrammedesequencesUMLdecrivantleuxcompletdecreationd'un
ticketdepuisl'applicationFlutterjusqu'alabasededonneesPostgreSQL,enpassant
parl'APIDjango(authenticationJWTincluse).
```
## 4 Phase 2 Developp ementBackendDjango

```
Phase 2 BackendDjangoRESTFramework
```
```
Miseenplacecompletedel'APIRESTavecDjango,gestiondesmo deles,desserial-
izers,desvues,desp ermissionsetdel'authenticationJWT.
```
### 4.1 Miseenplacedel'environnement

```
TravauxPratiques:Initialisationdupro jetDjango
```
```
Executezlescommandessuivantesp ourcreeretcongurerlepro jet:
```
```
# C r e e r e t a c t i v e r u n e n v i r o n n e m e n t v i r t u e l
p y t h o n - m v e n v v e n v
s o u r c e v e n v / b i n / a c t i v a t e # L i n u x / m a c O S
v e n v \ S c r i p t s \ a c t i v a t e # W i n d o w s
```

```
# I n s t a l l e r l e s d e p e n d a n c e s
p i p i n s t a l l d j a n g o d j a n g o r e s t f r a m e w o r k \
d j a n g o r e s t f r a m e w o r k - s i m p l e j w t \
d j a n g o - c o r s - h e a d e r s \
p s y c o p g 2 - b i n a r y \
P i l l o w
```
```
# C r e e r l e p r o j e t e t l e s a p p l i c a t i o n s
d j a n g o - a d m i n s t a r t p r o j e c t c o n f i g.
p y t h o n m a n a g e. p y s t a r t a p p t i c k e t s
p y t h o n m a n a g e. p y s t a r t a p p a c c o u n t s
```
#### 4.1.1 Congurationsettings.py

Listing1: settings.pycongurationprincipale
1 I N S T A L L E D _ A P P S = [
2 ' d j a n g o. c o n t r i b. a d m i n ' ,
3 ' d j a n g o. c o n t r i b. a u t h ' ,
4 ' d j a n g o. c o n t r i b. c o n t e n t t y p e s ' ,
5 ' d j a n g o. c o n t r i b. s e s s i o n s ' ,
6 ' d j a n g o. c o n t r i b. m e s s a g e s ' ,
7 ' d j a n g o. c o n t r i b. s t a t i c f i l e s ' ,
8 # A p p s t i e r c e s
9 ' r e s t _ f r a m e w o r k ' ,
10 ' r e s t _ f r a m e w o r k _ s i m p l e j w t ' ,
11 ' c o r s h e a d e r s ' ,
12 # N o s a p p l i c a t i o n s
13 ' a c c o u n t s ' ,
14 ' t i c k e t s ' ,
15 ]
16
17 M I D D L E W A R E = [
18 ' c o r s h e a d e r s. m i d d l e w a r e. C o r s M i d d l e w a r e ' , # e n p r e m i e r!
19 ' d j a n g o. m i d d l e w a r e. s e c u r i t y. S e c u r i t y M i d d l e w a r e ' ,
20 #... r e s t e d u m i d d l e w a r e
21 ]
22
23 # - - - - B a s e d e d o n n e e s P o s t g r e S Q L - - - -
24 D A T A B A S E S = {
25 ' d e f a u l t ' : {
26 ' E N G I N E ' : ' d j a n g o. d b. b a c k e n d s. p o s t g r e s q l ' ,
27 ' N A M E ' : ' r e c l a m a t i o n s _ d b ' ,
28 ' U S E R ' : ' p o s t g r e s ' ,
29 ' P A S S W O R D ' : ' m o t d e p a s s e ' ,
30 ' H O S T ' : ' l o c a l h o s t ' ,
31 ' P O R T ' : ' 5 4 3 2 ' ,
32 }
33 }
34
35 # - - - - D j a n g o R E S T F r a m e w o r k - - - -
36 R E S T _ F R A M E W O R K = {
37 ' D E F A U L T _ A U T H E N T I C A T I O N _ C L A S S E S ' : (


38 ' r e s t _ f r a m e w o r k _ s i m p l e j w t. a u t h e n t i c a t i o n.
J W T A u t h e n t i c a t i o n ' ,
39 ) ,
40 ' D E F A U L T _ P E R M I S S I O N _ C L A S S E S ' : (
41 ' r e s t _ f r a m e w o r k. p e r m i s s i o n s. I s A u t h e n t i c a t e d ' ,
42 ) ,
43 ' D E F A U L T _ P A G I N A T I O N _ C L A S S ' :
44 ' r e s t _ f r a m e w o r k. p a g i n a t i o n. P a g e N u m b e r P a g i n a t i o n ' ,
45 ' P A G E _ S I Z E ' : 2 0 ,
46 }
47
48 # - - - - S i m p l e J W T - - - -
49 f r o m d a t e t i m e i m p o r t t i m e d e l t a
50 S I M P L E _ J W T = {
51 ' A C C E S S _ T O K E N _ L I F E T I M E ' : t i m e d e l t a ( h o u r s = 2 ) ,
52 ' R E F R E S H _ T O K E N _ L I F E T I M E ' : t i m e d e l t a ( d a y s = 7 ) ,
53 ' A U T H _ H E A D E R _ T Y P E S ' : ( ' B e a r e r ' , ) ,
54 }
55
56 # - - - - C O R S ( p o u r F l u t t e r ) - - - -
57 C O R S _ A L L O W _ A L L _ O R I G I N S = T r u e # A r e s t r e i n d r e e n p r o d u c t i o n
58 A U T H _ U S E R _ M O D E L = ' a c c o u n t s. C u s t o m U s e r '

### 4.2 Mo delesdedonnees.

#### 4.2.1 Mo deleutilisateurp ersonnaliseaccounts/models.py

Listing2:accounts/mo dels.py
1 f r o m d j a n g o. c o n t r i b. a u t h. m o d e l s i m p o r t A b s t r a c t U s e r
2 f r o m d j a n g o. d b i m p o r t m o d e l s
3
4 c l a s s C u s t o m U s e r ( A b s t r a c t U s e r ) :
5 c l a s s R o l e ( m o d e l s. T e x t C h o i c e s ) :
6 C I T O Y E N = ' C I T O Y E N ' , ' C i t o y e n / A g e n t '
7 T E C H N I C I E N = ' T E C H N I C I E N ' , ' T e c h n i c i e n S u p p o r t '
8 A D M I N = ' A D M I N ' , ' A d m i n i s t r a t e u r '
9
10 e m a i l = m o d e l s. E m a i l F i e l d ( u n i q u e = T r u e )
11 r o l e = m o d e l s. C h a r F i e l d (
12 m a x _ l e n g t h = 1 5 , c h o i c e s = R o l e. c h o i c e s ,
13 d e f a u l t = R o l e. C I T O Y E N
14 )
15 t e l e p h o n e = m o d e l s. C h a r F i e l d ( m a x _ l e n g t h = 2 0 , b l a n k = T r u e )
16
17 U S E R N A M E _ F I E L D = ' e m a i l '
18 R E Q U I R E D _ F I E L D S = [ ' u s e r n a m e ' ]
19
20 d e f _ _ s t r _ _ ( s e l f ) :
21 r e t u r n f " { s e l f. g e t _ f u l l _ n a m e ( ) } ( { s e l f. r o l e } ) "
22
23 @ p r o p e r t y
24 d e f i s _ t e c h n i c i e n ( s e l f ) :


25 r e t u r n s e l f. r o l e = = s e l f. R o l e. T E C H N I C I E N
26
27 @ p r o p e r t y
28 d e f i s _ a d m i n _ r o l e ( s e l f ) :
29 r e t u r n s e l f. r o l e = = s e l f. R o l e. A D M I N

#### 4.2.2 Mo delesdesticketstickets/models.py

Listing3:tickets/mo dels.py
1 f r o m d j a n g o. d b i m p o r t m o d e l s
2 f r o m d j a n g o. c o n f i m p o r t s e t t i n g s
3
4 c l a s s T i c k e t ( m o d e l s. M o d e l ) :
5 c l a s s T y p e T i c k e t ( m o d e l s. T e x t C h o i c e s ) :
6 I N C I D E N T = ' I N C I D E N T ' , ' I n c i d e n t t e c h n i q u e '
7 R E C L A M A T I O N = ' R E C L A M A T I O N ' , ' R e c l a m a t i o n '
8 D E M A N D E = ' D E M A N D E ' , ' D e m a n d e d e s e r v i c e '
9
10 c l a s s S t a t u t ( m o d e l s. T e x t C h o i c e s ) :
11 O U V E R T = ' O U V E R T ' , ' O u v e r t '
12 E N _ C O U R S = ' E N _ C O U R S ' , ' E n c o u r s d e t r a i t e m e n t '
13 R E S O L U = ' R E S O L U ' , ' R e s o l u '
14 C L O S = ' C L O S ' , ' C l o s / A r c h i v e '
15
16 c l a s s P r i o r i t e ( m o d e l s. T e x t C h o i c e s ) :
17 B A S S E = ' B A S S E ' , ' B a s s e '
18 N O R M A L E = ' N O R M A L E ' , ' N o r m a l e '
19 H A U T E = ' H A U T E ' , ' H a u t e '
20 C R I T I Q U E = ' C R I T I Q U E ' , ' C r i t i q u e '
21
22 t i t r e = m o d e l s. C h a r F i e l d ( m a x _ l e n g t h = 2 0 0 )
23 d e s c r i p t i o n = m o d e l s. T e x t F i e l d ( )
24 t y p e _ t i c k e t = m o d e l s. C h a r F i e l d (
25 m a x _ l e n g t h = 1 5 , c h o i c e s = T y p e T i c k e t. c h o i c e s ,
26 d e f a u l t = T y p e T i c k e t. I N C I D E N T
27 )
28 s t a t u t = m o d e l s. C h a r F i e l d (
29 m a x _ l e n g t h = 1 0 , c h o i c e s = S t a t u t. c h o i c e s ,
30 d e f a u l t = S t a t u t. O U V E R T
31 )
32 p r i o r i t e = m o d e l s. C h a r F i e l d (
33 m a x _ l e n g t h = 1 0 , c h o i c e s = P r i o r i t e. c h o i c e s ,
34 d e f a u l t = P r i o r i t e. N O R M A L E
35 )
36 a u t e u r = m o d e l s. F o r e i g n K e y (
37 s e t t i n g s. A U T H _ U S E R _ M O D E L ,
38 o n _ d e l e t e = m o d e l s. C A S C A D E ,
39 r e l a t e d _ n a m e = ' t i c k e t s _ c r e e s '
40 )
41 a s s i g n e _ a = m o d e l s. F o r e i g n K e y (
42 s e t t i n g s. A U T H _ U S E R _ M O D E L ,
43 o n _ d e l e t e = m o d e l s. S E T _ N U L L ,


44 n u l l = T r u e , b l a n k = T r u e ,
45 r e l a t e d _ n a m e = ' t i c k e t s _ a s s i g n e s '
46 )
47 d a t e _ c r e a t i o n = m o d e l s. D a t e T i m e F i e l d ( a u t o _ n o w _ a d d = T r u e )
48 d a t e _ m o d i f i c a t i o n = m o d e l s. D a t e T i m e F i e l d ( a u t o _ n o w = T r u e )
49 d a t e _ r e s o l u t i o n = m o d e l s. D a t e T i m e F i e l d ( n u l l = T r u e , b l a n k = T r u e
)
50
51 c l a s s M e t a :
52 o r d e r i n g = [ ' - d a t e _ c r e a t i o n ' ]
53 v e r b o s e _ n a m e = ' T i c k e t '
54 v e r b o s e _ n a m e _ p l u r a l = ' T i c k e t s '
55
56 d e f _ _ s t r _ _ ( s e l f ) :
57 r e t u r n f " [ { s e l f. s t a t u t } ] { s e l f. t i t r e } "
58
59
60 c l a s s C o m m e n t a i r e ( m o d e l s. M o d e l ) :
61 t i c k e t = m o d e l s. F o r e i g n K e y (
62 T i c k e t , o n _ d e l e t e = m o d e l s. C A S C A D E ,
63 r e l a t e d _ n a m e = ' c o m m e n t a i r e s '
64 )
65 a u t e u r = m o d e l s. F o r e i g n K e y (
66 s e t t i n g s. A U T H _ U S E R _ M O D E L ,
67 o n _ d e l e t e = m o d e l s. C A S C A D E
68 )
69 c o n t e n u = m o d e l s. T e x t F i e l d ( )
70 d a t e = m o d e l s. D a t e T i m e F i e l d ( a u t o _ n o w _ a d d = T r u e )
71
72 c l a s s M e t a :
73 o r d e r i n g = [ ' d a t e ' ]
74
75 d e f _ _ s t r _ _ ( s e l f ) :
76 r e t u r n f " C o m m e n t a i r e d e { s e l f. a u t e u r } s u r # { s e l f. t i c k e t.
i d } "
77
78
79 c l a s s H i s t o r i q u e S t a t u t ( m o d e l s. M o d e l ) :
80 t i c k e t = m o d e l s. F o r e i g n K e y (
81 T i c k e t , o n _ d e l e t e = m o d e l s. C A S C A D E ,
82 r e l a t e d _ n a m e = ' h i s t o r i q u e '
83 )
84 a n c i e n _ s t a t u t = m o d e l s. C h a r F i e l d ( m a x _ l e n g t h = 1 0 )
85 n o u v e a u _ s t a t u t = m o d e l s. C h a r F i e l d ( m a x _ l e n g t h = 1 0 )
86 d a t e _ c h a n g e m e n t = m o d e l s. D a t e T i m e F i e l d ( a u t o _ n o w _ a d d = T r u e )
87 m o d i f i e _ p a r = m o d e l s. F o r e i g n K e y (
88 s e t t i n g s. A U T H _ U S E R _ M O D E L ,
89 o n _ d e l e t e = m o d e l s. S E T _ N U L L , n u l l = T r u e
90 )
91
92 c l a s s M e t a :


93 o r d e r i n g = [ ' - d a t e _ c h a n g e m e n t ' ]

```
TravauxPratiques:Migrationdelabasededonnees
```
```
Apresavoirdenivosmo deles,creezlabasededonneesPostgreSQLeteectuezles
migrations:
# C r e e r l a B D D P o s t g r e S Q L
c r e a t e d b r e c l a m a t i o n s _ d b # o u v i a p s q l
```
```
# E f f e c t u e r l e s m i g r a t i o n s
p y t h o n m a n a g e. p y m a k e m i g r a t i o n s a c c o u n t s t i c k e t s
p y t h o n m a n a g e. p y m i g r a t e
```
```
# C r e e r u n s u p e r u t i l i s a t e u r
p y t h o n m a n a g e. p y c r e a t e s u p e r u s e r
```
### 4.3 SerializersDRF

```
Listing4:tickets/serializers.py
1 f r o m r e s t _ f r a m e w o r k i m p o r t s e r i a l i z e r s
2 f r o m. m o d e l s i m p o r t T i c k e t , C o m m e n t a i r e , H i s t o r i q u e S t a t u t
3 f r o m a c c o u n t s. m o d e l s i m p o r t C u s t o m U s e r
4
5
6 c l a s s U s e r L i g h t S e r i a l i z e r ( s e r i a l i z e r s. M o d e l S e r i a l i z e r ) :
7 " " " S e r i a l i z e r l e g e r p o u r a f f i c h e r l e s i n f o s d ' u n u t i l i s a t e u r
```
. " " "
8 c l a s s M e t a :
9 m o d e l = C u s t o m U s e r
10 f i e l d s = [ ' i d ' , ' f i r s t _ n a m e ' , ' l a s t _ n a m e ' , ' e m a i l ' , '
r o l e ' ]
11
12
13 c l a s s C o m m e n t a i r e S e r i a l i z e r ( s e r i a l i z e r s. M o d e l S e r i a l i z e r ) :
14 a u t e u r = U s e r L i g h t S e r i a l i z e r ( r e a d _ o n l y = T r u e )
15
16 c l a s s M e t a :
17 m o d e l = C o m m e n t a i r e
18 f i e l d s = [ ' i d ' , ' a u t e u r ' , ' c o n t e n u ' , ' d a t e ' ]
19 r e a d _ o n l y _ f i e l d s = [ ' a u t e u r ' , ' d a t e ' ]
20
21
22 c l a s s H i s t o r i q u e S t a t u t S e r i a l i z e r ( s e r i a l i z e r s. M o d e l S e r i a l i z e r ) :
23 m o d i f i e _ p a r = U s e r L i g h t S e r i a l i z e r ( r e a d _ o n l y = T r u e )
24
25 c l a s s M e t a :
26 m o d e l = H i s t o r i q u e S t a t u t
27 f i e l d s = [ ' i d ' , ' a n c i e n _ s t a t u t ' , ' n o u v e a u _ s t a t u t ' ,
28 ' d a t e _ c h a n g e m e n t ' , ' m o d i f i e _ p a r ' ]


29
30
31 c l a s s T i c k e t S e r i a l i z e r ( s e r i a l i z e r s. M o d e l S e r i a l i z e r ) :
32 a u t e u r = U s e r L i g h t S e r i a l i z e r ( r e a d _ o n l y = T r u e )
33 a s s i g n e _ a = U s e r L i g h t S e r i a l i z e r ( r e a d _ o n l y = T r u e )
34 c o m m e n t a i r e s = C o m m e n t a i r e S e r i a l i z e r ( m a n y = T r u e , r e a d _ o n l y =
T r u e )
35 h i s t o r i q u e = H i s t o r i q u e S t a t u t S e r i a l i z e r ( m a n y = T r u e ,
r e a d _ o n l y = T r u e )
36 a s s i g n e _ a _ i d = s e r i a l i z e r s. P r i m a r y K e y R e l a t e d F i e l d (
37 s o u r c e = ' a s s i g n e _ a ' ,
38 q u e r y s e t = C u s t o m U s e r. o b j e c t s. f i l t e r ( r o l e = ' T E C H N I C I E N ' ) ,
39 w r i t e _ o n l y = T r u e , r e q u i r e d = F a l s e , a l l o w _ n u l l = T r u e
40 )
41
42 c l a s s M e t a :
43 m o d e l = T i c k e t
44 f i e l d s = [
45 ' i d ' , ' t i t r e ' , ' d e s c r i p t i o n ' , ' t y p e _ t i c k e t ' ,
46 ' s t a t u t ' , ' p r i o r i t e ' , ' a u t e u r ' , ' a s s i g n e _ a ' ,
47 ' a s s i g n e _ a _ i d ' , ' d a t e _ c r e a t i o n ' ,
48 ' d a t e _ m o d i f i c a t i o n ' , ' d a t e _ r e s o l u t i o n ' ,
49 ' c o m m e n t a i r e s ' , ' h i s t o r i q u e ' ,
50 ]
51 r e a d _ o n l y _ f i e l d s = [ ' a u t e u r ' , ' d a t e _ c r e a t i o n ' , '
d a t e _ m o d i f i c a t i o n ' ]
52
53 d e f c r e a t e ( s e l f , v a l i d a t e d _ d a t a ) :
54 # L ' a u t e u r e s t a u t o m a t i q u e m e n t l ' u t i l i s a t e u r c o n n e c t e
55 v a l i d a t e d _ d a t a [ ' a u t e u r ' ] = s e l f. c o n t e x t [ ' r e q u e s t ' ]. u s e r
56 r e t u r n s u p e r ( ). c r e a t e ( v a l i d a t e d _ d a t a )
57
58
59 c l a s s T i c k e t L i s t S e r i a l i z e r ( s e r i a l i z e r s. M o d e l S e r i a l i z e r ) :
60 " " " S e r i a l i z e r a l l e g e p o u r l e s l i s t e s ( s a n s c o m m e n t a i r e s ). " " "
61 a u t e u r = U s e r L i g h t S e r i a l i z e r ( r e a d _ o n l y = T r u e )
62 a s s i g n e _ a = U s e r L i g h t S e r i a l i z e r ( r e a d _ o n l y = T r u e )
63
64 c l a s s M e t a :
65 m o d e l = T i c k e t
66 f i e l d s = [ ' i d ' , ' t i t r e ' , ' t y p e _ t i c k e t ' , ' s t a t u t ' ,
67 ' p r i o r i t e ' , ' a u t e u r ' , ' a s s i g n e _ a ' , '
d a t e _ c r e a t i o n ' ]

### 4.4 Permissionsp ersonnalisees

```
Listing5: tickets/p ermissions.py
1 f r o m r e s t _ f r a m e w o r k. p e r m i s s i o n s i m p o r t B a s e P e r m i s s i o n ,
S A F E _ M E T H O D S
2
3
```

4 c l a s s I s A u t e u r O r R e a d O n l y ( B a s e P e r m i s s i o n ) :
5 " " " S e u l l ' a u t e u r p e u t m o d i f i e r s o n t i c k e t. " " "
6 d e f h a s _ o b j e c t _ p e r m i s s i o n ( s e l f , r e q u e s t , v i e w , o b j ) :
7 i f r e q u e s t. m e t h o d i n S A F E _ M E T H O D S :
8 r e t u r n T r u e
9 r e t u r n o b j. a u t e u r = = r e q u e s t. u s e r
10
11
12 c l a s s I s T e c h n i c i e n O r A d m i n ( B a s e P e r m i s s i o n ) :
13 " " " S e u l s l e s t e c h n i c i e n s e t a d m i n s p e u v e n t c h a n g e r l e s t a t u t

. " " "
14 d e f h a s _ p e r m i s s i o n ( s e l f , r e q u e s t , v i e w ) :
15 r e t u r n r e q u e s t. u s e r. r o l e i n ( ' T E C H N I C I E N ' , ' A D M I N ' )
16
17
18 c l a s s I s A d m i n R o l e ( B a s e P e r m i s s i o n ) :
19 " " " R e s e r v e a u x a d m i n i s t r a t e u r s. " " "
20 d e f h a s _ p e r m i s s i o n ( s e l f , r e q u e s t , v i e w ) :
21 r e t u r n r e q u e s t. u s e r. r o l e = = ' A D M I N '

### 4.5 VuesetEndp ointsAPI

Listing6:tickets/views.py
1 f r o m r e s t _ f r a m e w o r k i m p o r t v i e w s e t s , s t a t u s , f i l t e r s
2 f r o m r e s t _ f r a m e w o r k. d e c o r a t o r s i m p o r t a c t i o n
3 f r o m r e s t _ f r a m e w o r k. r e s p o n s e i m p o r t R e s p o n s e
4 f r o m r e s t _ f r a m e w o r k. p e r m i s s i o n s i m p o r t I s A u t h e n t i c a t e d
5 f r o m d j a n g o _ f i l t e r s. r e s t _ f r a m e w o r k i m p o r t D j a n g o F i l t e r B a c k e n d
6 f r o m d j a n g o. u t i l s i m p o r t t i m e z o n e
7
8 f r o m. m o d e l s i m p o r t T i c k e t , C o m m e n t a i r e , H i s t o r i q u e S t a t u t
9 f r o m. s e r i a l i z e r s i m p o r t (
10 T i c k e t S e r i a l i z e r , T i c k e t L i s t S e r i a l i z e r ,
11 C o m m e n t a i r e S e r i a l i z e r
12 )
13 f r o m. p e r m i s s i o n s i m p o r t I s A u t e u r O r R e a d O n l y , I s T e c h n i c i e n O r A d m i n
14
15
16 c l a s s T i c k e t V i e w S e t ( v i e w s e t s. M o d e l V i e w S e t ) :
17 " " "
18 V i e w S e t c o m p l e t p o u r l a g e s t i o n d e s t i c k e t s.
19 - l i s t : G E T / a p i / t i c k e t s /
20 - c r e a t e : P O S T / a p i / t i c k e t s /
21 - r e t r i e v e : G E T / a p i / t i c k e t s / { i d } /
22 - u p d a t e : P U T / P A T C H / a p i / t i c k e t s / { i d } /
23 - d e s t r o y : D E L E T E / a p i / t i c k e t s / { i d } /
24 " " "
25 q u e r y s e t = T i c k e t. o b j e c t s. s e l e c t _ r e l a t e d (
26 ' a u t e u r ' , ' a s s i g n e _ a '
27 ). p r e f e t c h _ r e l a t e d ( ' c o m m e n t a i r e s ' , ' h i s t o r i q u e ' )
28 p e r m i s s i o n _ c l a s s e s = [ I s A u t h e n t i c a t e d ]


29 f i l t e r _ b a c k e n d s = [
30 D j a n g o F i l t e r B a c k e n d ,
31 f i l t e r s. S e a r c h F i l t e r ,
32 f i l t e r s. O r d e r i n g F i l t e r ,
33 ]
34 f i l t e r s e t _ f i e l d s = [ ' s t a t u t ' , ' p r i o r i t e ' , ' t y p e _ t i c k e t ' ,
35 ' a s s i g n e _ a ' ]
36 s e a r c h _ f i e l d s = [ ' t i t r e ' , ' d e s c r i p t i o n ' ]
37 o r d e r i n g _ f i e l d s = [ ' d a t e _ c r e a t i o n ' , ' p r i o r i t e ' , ' s t a t u t ' ]
38
39 d e f g e t _ s e r i a l i z e r _ c l a s s ( s e l f ) :
40 i f s e l f. a c t i o n = = ' l i s t ' :
41 r e t u r n T i c k e t L i s t S e r i a l i z e r
42 r e t u r n T i c k e t S e r i a l i z e r
43
44 d e f g e t _ q u e r y s e t ( s e l f ) :
45 u s e r = s e l f. r e q u e s t. u s e r
46 # U n c i t o y e n n e v o i t q u e s e s p r o p r e s t i c k e t s
47 i f u s e r. r o l e = = ' C I T O Y E N ' :
48 r e t u r n T i c k e t. o b j e c t s. f i l t e r ( a u t e u r = u s e r )
49 # T e c h n i c i e n v o i t l e s t i c k e t s a s s i g n e s + l e s o u v e r t s
50 i f u s e r. r o l e = = ' T E C H N I C I E N ' :
51 r e t u r n T i c k e t. o b j e c t s. f i l t e r (
52 m o d e l s. Q ( a s s i g n e _ a = u s e r ) |
53 m o d e l s. Q ( s t a t u t = ' O U V E R T ' )
54 )
55 # A d m i n v o i t t o u t
56 r e t u r n T i c k e t. o b j e c t s. a l l ( )
57
58 @ a c t i o n ( d e t a i l = T r u e , m e t h o d s = [ ' p a t c h ' ] ,
59 p e r m i s s i o n _ c l a s s e s = [ I s T e c h n i c i e n O r A d m i n ] )
60 d e f c h a n g e r _ s t a t u t ( s e l f , r e q u e s t , p k = N o n e ) :
61 " " " P U T / a p i / t i c k e t s / { i d } / c h a n g e r _ s t a t u t / " " "
62 t i c k e t = s e l f. g e t _ o b j e c t ( )
63 n o u v e a u _ s t a t u t = r e q u e s t. d a t a. g e t ( ' s t a t u t ' )
64 i f n o u v e a u _ s t a t u t n o t i n d i c t ( T i c k e t. S t a t u t. c h o i c e s ) :
65 r e t u r n R e s p o n s e (
66 { ' e r r e u r ' : ' S t a t u t i n v a l i d e. ' } ,
67 s t a t u s = s t a t u s. H T T P _ 4 0 0 _ B A D _ R E Q U E S T
68 )
69 a n c i e n _ s t a t u t = t i c k e t. s t a t u t
70 t i c k e t. s t a t u t = n o u v e a u _ s t a t u t
71 i f n o u v e a u _ s t a t u t = = T i c k e t. S t a t u t. R E S O L U :
72 t i c k e t. d a t e _ r e s o l u t i o n = t i m e z o n e. n o w ( )
73 t i c k e t. s a v e ( )
74 # E n r e g i s t r e r l ' h i s t o r i q u e
75 H i s t o r i q u e S t a t u t. o b j e c t s. c r e a t e (
76 t i c k e t = t i c k e t ,
77 a n c i e n _ s t a t u t = a n c i e n _ s t a t u t ,
78 n o u v e a u _ s t a t u t = n o u v e a u _ s t a t u t ,
79 m o d i f i e _ p a r = r e q u e s t. u s e r ,


80 )
81 r e t u r n R e s p o n s e ( T i c k e t S e r i a l i z e r (
82 t i c k e t , c o n t e x t = { ' r e q u e s t ' : r e q u e s t }
83 ). d a t a )
84
85 @ a c t i o n ( d e t a i l = T r u e , m e t h o d s = [ ' p o s t ' ] )
86 d e f c o m m e n t e r ( s e l f , r e q u e s t , p k = N o n e ) :
87 " " " P O S T / a p i / t i c k e t s / { i d } / c o m m e n t e r / " " "
88 t i c k e t = s e l f. g e t _ o b j e c t ( )
89 s e r i a l i z e r = C o m m e n t a i r e S e r i a l i z e r ( d a t a = r e q u e s t. d a t a )
90 i f s e r i a l i z e r. i s _ v a l i d ( ) :
91 s e r i a l i z e r. s a v e ( t i c k e t = t i c k e t , a u t e u r = r e q u e s t. u s e r )
92 r e t u r n R e s p o n s e ( s e r i a l i z e r. d a t a ,
93 s t a t u s = s t a t u s. H T T P _ 2 0 1 _ C R E A T E D )
94 r e t u r n R e s p o n s e ( s e r i a l i z e r. e r r o r s ,
95 s t a t u s = s t a t u s. H T T P _ 4 0 0 _ B A D _ R E Q U E S T )
96
97 @ a c t i o n ( d e t a i l = T r u e , m e t h o d s = [ ' p a t c h ' ] ,
98 p e r m i s s i o n _ c l a s s e s = [ I s T e c h n i c i e n O r A d m i n ] )
99 d e f a s s i g n e r ( s e l f , r e q u e s t , p k = N o n e ) :
100 " " " P A T C H / a p i / t i c k e t s / { i d } / a s s i g n e r / " " "
101 t i c k e t = s e l f. g e t _ o b j e c t ( )
102 t e c h n i c i e n _ i d = r e q u e s t. d a t a. g e t ( ' t e c h n i c i e n _ i d ' )
103 t r y :
104 f r o m a c c o u n t s. m o d e l s i m p o r t C u s t o m U s e r
105 t e c h = C u s t o m U s e r. o b j e c t s. g e t (
106 i d = t e c h n i c i e n _ i d , r o l e = ' T E C H N I C I E N '
107 )
108 t i c k e t. a s s i g n e _ a = t e c h
109 t i c k e t. s t a t u t = T i c k e t. S t a t u t. E N _ C O U R S
110 t i c k e t. s a v e ( )
111 r e t u r n R e s p o n s e ( T i c k e t S e r i a l i z e r (
112 t i c k e t , c o n t e x t = { ' r e q u e s t ' : r e q u e s t }
113 ). d a t a )
114 e x c e p t C u s t o m U s e r. D o e s N o t E x i s t :
115 r e t u r n R e s p o n s e ( { ' e r r e u r ' : ' T e c h n i c i e n i n t r o u v a b l e. '
} ,
116 s t a t u s = s t a t u s. H T T P _ 4 0 4 _ N O T _ F O U N D )

### 4.6 URLsdel'API

```
Listing7:cong/urls.py
1 f r o m d j a n g o. c o n t r i b i m p o r t a d m i n
2 f r o m d j a n g o. u r l s i m p o r t p a t h , i n c l u d e
3 f r o m r e s t _ f r a m e w o r k. r o u t e r s i m p o r t D e f a u l t R o u t e r
4 f r o m r e s t _ f r a m e w o r k _ s i m p l e j w t. v i e w s i m p o r t (
5 T o k e n O b t a i n P a i r V i e w , T o k e n R e f r e s h V i e w
6 )
7 f r o m t i c k e t s. v i e w s i m p o r t T i c k e t V i e w S e t
8 f r o m a c c o u n t s. v i e w s i m p o r t R e g i s t e r V i e w , P r o f i l e V i e w
9
```

10 r o u t e r = D e f a u l t R o u t e r ( )
11 r o u t e r. r e g i s t e r ( r ' t i c k e t s ' , T i c k e t V i e w S e t , b a s e n a m e = ' t i c k e t ' )
12
13 u r l p a t t e r n s = [
14 p a t h ( ' a d m i n / ' , a d m i n. s i t e. u r l s ) ,
15 # A u t h e n t i f i c a t i o n J W T
16 p a t h ( ' a p i / a u t h / l o g i n / ' ,
17 T o k e n O b t a i n P a i r V i e w. a s _ v i e w ( ) , n a m e = ' t o k e n _ o b t a i n ' ) ,
18 p a t h ( ' a p i / a u t h / r e f r e s h / ' ,
19 T o k e n R e f r e s h V i e w. a s _ v i e w ( ) , n a m e = ' t o k e n _ r e f r e s h ' ) ,
20 p a t h ( ' a p i / a u t h / r e g i s t e r / ' ,
21 R e g i s t e r V i e w. a s _ v i e w ( ) , n a m e = ' r e g i s t e r ' ) ,
22 p a t h ( ' a p i / a u t h / p r o f i l / ' ,
23 P r o f i l e V i e w. a s _ v i e w ( ) , n a m e = ' p r o f i l ' ) ,
24 # A P I t i c k e t s
25 p a t h ( ' a p i / ' , i n c l u d e ( r o u t e r. u r l s ) ) ,
26 ]

```
Metho de Endp oint Description Acces
POST /api/auth/login/ Obtenir access
+refreshtoken
```
```
Tous
```
```
POST /api/auth/refresh/ Renouveler
l'accesstoken
```
```
Tokenvalide
```
```
POST /api/auth/register/ Creeruncompte Public
GET /api/tickets/ Listerlestickets Connecte
POST /api/tickets/ Creerunticket Connecte
GET /api/tickets/{id}/ Detail d'un
ticket
```
```
Connecte
```
```
PATCH /api/tickets/{id}/changer_statut/ Changer le
statut
```
```
Tech/Admin
```
```
POST /api/tickets/{id}/commenter/ Ajouteruncom-
mentaire
```
```
Connecte
```
```
PATCH /api/tickets/{id}/assigner/ Assigner a un
technicien
```
```
Tech/Admin
```
```
TravauxPratiques:Lancementettestduserveur
```
```
p y t h o n m a n a g e. p y r u n s e r v e r
```
```
# T e s t e r a v e c c u r l o u h t t p i e
c u r l - X P O S T h t t p : / / 1 2 7. 0. 0. 1 : 8 0 0 0 / a p i / a u t h / l o g i n / \
```
- H " C o n t e n t - T y p e : a p p l i c a t i o n / j s o n " \
- d ' { " e m a i l " : " u s e r @ t e s t. c o m " , " p a s s w o r d " : " p a s s 1 2 3 4 " } '
Vousobtenez unaccesstoken etun refreshtoken au formatJSON. Utilisezle
tokend'accesdanslesrequetes suivantesavecleheaderAuthorization: Bearer
<token>.


## 5 Phase 3 Developp ementFrontendFlutter

```
Phase 3 FrontendFlutter/Dart
```
```
Developp ementdel'applicationmobileFlutterquiconsommel'APIDjangoREST.
Vousallezimplementerlesystemed'authentication,lalistedestickets,lacreation
etledetaild'unticket.
```
### 5.1 Initialisationdupro jetFlutter.

```
f l u t t e r c r e a t e r e c l a m a t i o n s _ a p p
c d r e c l a m a t i o n s _ a p p
```
#### 5.1.1 Dep endancespubspec.yaml.

```
d e p e n d e n c i e s :
f l u t t e r :
s d k : f l u t t e r
h t t p : ^ 1. 2. 0
s h a r e d _ p r e f e r e n c e s : ^ 2. 2. 2
p r o v i d e r : ^ 6. 1. 2
i n t l : ^ 0. 1 9. 0
```
```
d e v _ d e p e n d e n c i e s :
f l u t t e r _ t e s t :
s d k : f l u t t e r
```
### 5.2 Mo delesDart

Listing8:lib/mo dels/ticket.dart
1 c l a s s T i c k e t {
2 f i n a l i n t i d ;
3 f i n a l S t r i n g t i t r e ;
4 f i n a l S t r i n g d e s c r i p t i o n ;
5 f i n a l S t r i n g t y p e T i c k e t ;
6 f i n a l S t r i n g s t a t u t ;
7 f i n a l S t r i n g p r i o r i t e ;
8 f i n a l S t r i n g a u t e u r N o m ;
9 f i n a l S t r i n g d a t e C r e a t i o n ;
10 f i n a l S t r i n g? a s s i g n e A ;
11
12 T i c k e t ( {
13 r e q u i r e d t h i s. i d ,
14 r e q u i r e d t h i s. t i t r e ,
15 r e q u i r e d t h i s. d e s c r i p t i o n ,
16 r e q u i r e d t h i s. t y p e T i c k e t ,
17 r e q u i r e d t h i s. s t a t u t ,
18 r e q u i r e d t h i s. p r i o r i t e ,
19 r e q u i r e d t h i s. a u t e u r N o m ,
20 r e q u i r e d t h i s. d a t e C r e a t i o n ,


21 t h i s. a s s i g n e A ,
22 } ) ;
23
24 f a c t o r y T i c k e t. f r o m J s o n ( M a p < S t r i n g , d y n a m i c > j s o n ) {
25 f i n a l a u t e u r = j s o n [ ' a u t e u r ' ] a s M a p < S t r i n g , d y n a m i c >? ;
26 f i n a l a s s i g n e = j s o n [ ' a s s i g n e _ a ' ] a s M a p < S t r i n g , d y n a m i c >? ;
27 r e t u r n T i c k e t (
28 i d : j s o n [ ' i d ' ] ,
29 t i t r e : j s o n [ ' t i t r e ' ] ,
30 d e s c r i p t i o n : j s o n [ ' d e s c r i p t i o n ' ] ,
31 t y p e T i c k e t : j s o n [ ' t y p e _ t i c k e t ' ] ,
32 s t a t u t : j s o n [ ' s t a t u t ' ] ,
33 p r i o r i t e : j s o n [ ' p r i o r i t e ' ] ,
34 a u t e u r N o m : a u t e u r! = n u l l
35? ' $ { a u t e u r [ " f i r s t _ n a m e " ] } $ { a u t e u r [ " l a s t _ n a m e " ] } '
36 : ' I n c o n n u ' ,
37 d a t e C r e a t i o n : j s o n [ ' d a t e _ c r e a t i o n ' ]?? ' ' ,
38 a s s i g n e A : a s s i g n e! = n u l l
39? ' $ { a s s i g n e [ " f i r s t _ n a m e " ] } $ { a s s i g n e [ " l a s t _ n a m e " ] } '
40 : n u l l ,
41 ) ;
42 }
43
44 M a p < S t r i n g , d y n a m i c > t o J s o n ( ) = > {
45 ' t i t r e ' : t i t r e ,
46 ' d e s c r i p t i o n ' : d e s c r i p t i o n ,
47 ' t y p e _ t i c k e t ' : t y p e T i c k e t ,
48 ' p r i o r i t e ' : p r i o r i t e ,
49 } ;
50 }

### 5.3 Serviced'authentication.

Listing9:lib/services/auth_service.dart
1 i m p o r t ' d a r t : c o n v e r t ' ;
2 i m p o r t ' p a c k a g e : h t t p / h t t p. d a r t ' a s h t t p ;
3 i m p o r t ' p a c k a g e : s h a r e d _ p r e f e r e n c e s / s h a r e d _ p r e f e r e n c e s. d a r t ' ;
4
5 c l a s s A u t h S e r v i c e {
6 s t a t i c c o n s t S t r i n g b a s e U r l = ' h t t p : / / 1 0. 0. 2. 2 : 8 0 0 0 / a p i ' ;
7 / / 1 0. 0. 2. 2 = l o c a l h o s t d e p u i s l ' e m u l a t e u r A n d r o i d
8
9 F u t u r e < M a p < S t r i n g , d y n a m i c > > l o g i n (
10 S t r i n g e m a i l , S t r i n g p a s s w o r d ) a s y n c {
11 f i n a l r e s p o n s e = a w a i t h t t p. p o s t (
12 U r i. p a r s e ( ' $ b a s e U r l / a u t h / l o g i n / ' ) ,
13 h e a d e r s : { ' C o n t e n t - T y p e ' : ' a p p l i c a t i o n / j s o n ' } ,
14 b o d y : j s o n E n c o d e ( { ' e m a i l ' : e m a i l , ' p a s s w o r d ' : p a s s w o r d } ) ,
15 ) ;
16 i f ( r e s p o n s e. s t a t u s C o d e = = 2 0 0 ) {
17 f i n a l d a t a = j s o n D e c o d e ( r e s p o n s e. b o d y ) ;


18 f i n a l p r e f s = a w a i t S h a r e d P r e f e r e n c e s. g e t I n s t a n c e ( ) ;
19 a w a i t p r e f s. s e t S t r i n g ( ' a c c e s s _ t o k e n ' , d a t a [ ' a c c e s s ' ] ) ;
20 a w a i t p r e f s. s e t S t r i n g ( ' r e f r e s h _ t o k e n ' , d a t a [ ' r e f r e s h ' ] ) ;
21 r e t u r n { ' s u c c e s s ' : t r u e } ;
22 }
23 r e t u r n { ' s u c c e s s ' : f a l s e ,
24 ' m e s s a g e ' : ' E m a i l o u m o t d e p a s s e i n c o r r e c t. ' } ;
25 }
26
27 F u t u r e < v o i d > l o g o u t ( ) a s y n c {
28 f i n a l p r e f s = a w a i t S h a r e d P r e f e r e n c e s. g e t I n s t a n c e ( ) ;
29 a w a i t p r e f s. r e m o v e ( ' a c c e s s _ t o k e n ' ) ;
30 a w a i t p r e f s. r e m o v e ( ' r e f r e s h _ t o k e n ' ) ;
31 }
32
33 F u t u r e < S t r i n g? > g e t A c c e s s T o k e n ( ) a s y n c {
34 f i n a l p r e f s = a w a i t S h a r e d P r e f e r e n c e s. g e t I n s t a n c e ( ) ;
35 r e t u r n p r e f s. g e t S t r i n g ( ' a c c e s s _ t o k e n ' ) ;
36 }
37
38 F u t u r e < b o o l > i s L o g g e d I n ( ) a s y n c {
39 f i n a l t o k e n = a w a i t g e t A c c e s s T o k e n ( ) ;
40 r e t u r n t o k e n! = n u l l & & t o k e n. i s N o t E m p t y ;
41 }
42 }

### 5.4 Servicedegestiondestickets.

Listing10:lib/services/ticket_service.dart
1 i m p o r t ' d a r t : c o n v e r t ' ;
2 i m p o r t ' p a c k a g e : h t t p / h t t p. d a r t ' a s h t t p ;
3 i m p o r t '.. / m o d e l s / t i c k e t. d a r t ' ;
4 i m p o r t ' a u t h _ s e r v i c e. d a r t ' ;
5
6 c l a s s T i c k e t S e r v i c e {
7 s t a t i c c o n s t S t r i n g _ b a s e = ' h t t p : / / 1 0. 0. 2. 2 : 8 0 0 0 / a p i / t i c k e t s '
;
8 f i n a l A u t h S e r v i c e _ a u t h = A u t h S e r v i c e ( ) ;
9
10 F u t u r e < M a p < S t r i n g , S t r i n g > > _ h e a d e r s ( ) a s y n c {
11 f i n a l t o k e n = a w a i t _ a u t h. g e t A c c e s s T o k e n ( ) ;
12 r e t u r n {
13 ' C o n t e n t - T y p e ' : ' a p p l i c a t i o n / j s o n ' ,
14 ' A u t h o r i z a t i o n ' : ' B e a r e r $ t o k e n ' ,
15 } ;
16 }
17
18 F u t u r e < L i s t < T i c k e t > > l i s t e r T i c k e t s ( {
19 S t r i n g? s t a t u t , S t r i n g? p r i o r i t e
20 } ) a s y n c {
21 S t r i n g u r l = _ b a s e + ' / ' ;


22 f i n a l p a r a m s = < S t r i n g , S t r i n g > { } ;
23 i f ( s t a t u t! = n u l l ) p a r a m s [ ' s t a t u t ' ] = s t a t u t ;
24 i f ( p r i o r i t e! = n u l l ) p a r a m s [ ' p r i o r i t e ' ] = p r i o r i t e ;
25 i f ( p a r a m s. i s N o t E m p t y ) {
26 u r l + = '? ' + U r i ( q u e r y P a r a m e t e r s : p a r a m s ). q u e r y ;
27 }
28 f i n a l r e s p o n s e = a w a i t h t t p. g e t (
29 U r i. p a r s e ( u r l ) , h e a d e r s : a w a i t _ h e a d e r s ( ) ,
30 ) ;
31 i f ( r e s p o n s e. s t a t u s C o d e = = 2 0 0 ) {
32 f i n a l d a t a = j s o n D e c o d e ( r e s p o n s e. b o d y ) ;
33 f i n a l L i s t r e s u l t s = d a t a [ ' r e s u l t s ' ]?? d a t a ;
34 r e t u r n r e s u l t s. m a p ( ( j ) = > T i c k e t. f r o m J s o n ( j ) ). t o L i s t ( ) ;
35 }
36 t h r o w E x c e p t i o n ( ' I m p o s s i b l e d e c h a r g e r l e s t i c k e t s. ' ) ;
37 }
38
39 F u t u r e < T i c k e t > g e t T i c k e t ( i n t i d ) a s y n c {
40 f i n a l r e s p o n s e = a w a i t h t t p. g e t (
41 U r i. p a r s e ( ' $ _ b a s e / $ i d / ' ) , h e a d e r s : a w a i t _ h e a d e r s ( ) ,
42 ) ;
43 i f ( r e s p o n s e. s t a t u s C o d e = = 2 0 0 ) {
44 r e t u r n T i c k e t. f r o m J s o n ( j s o n D e c o d e ( r e s p o n s e. b o d y ) ) ;
45 }
46 t h r o w E x c e p t i o n ( ' T i c k e t i n t r o u v a b l e. ' ) ;
47 }
48
49 F u t u r e < T i c k e t > c r e e r T i c k e t ( M a p < S t r i n g , d y n a m i c > d a t a ) a s y n c {
50 f i n a l r e s p o n s e = a w a i t h t t p. p o s t (
51 U r i. p a r s e ( ' $ _ b a s e / ' ) ,
52 h e a d e r s : a w a i t _ h e a d e r s ( ) ,
53 b o d y : j s o n E n c o d e ( d a t a ) ,
54 ) ;
55 i f ( r e s p o n s e. s t a t u s C o d e = = 2 0 1 ) {
56 r e t u r n T i c k e t. f r o m J s o n ( j s o n D e c o d e ( r e s p o n s e. b o d y ) ) ;
57 }
58 t h r o w E x c e p t i o n ( ' E r r e u r l o r s d e l a c r e a t i o n d u t i c k e t. ' ) ;
59 }
60
61 F u t u r e < v o i d > c h a n g e r S t a t u t ( i n t i d , S t r i n g n o u v e a u S t a t u t ) a s y n c
{
62 a w a i t h t t p. p a t c h (
63 U r i. p a r s e ( ' $ _ b a s e / $ i d / c h a n g e r _ s t a t u t / ' ) ,
64 h e a d e r s : a w a i t _ h e a d e r s ( ) ,
65 b o d y : j s o n E n c o d e ( { ' s t a t u t ' : n o u v e a u S t a t u t } ) ,
66 ) ;
67 }
68
69 F u t u r e < v o i d > c o m m e n t e r ( i n t i d , S t r i n g c o n t e n u ) a s y n c {
70 a w a i t h t t p. p o s t (
71 U r i. p a r s e ( ' $ _ b a s e / $ i d / c o m m e n t e r / ' ) ,


72 h e a d e r s : a w a i t _ h e a d e r s ( ) ,
73 b o d y : j s o n E n c o d e ( { ' c o n t e n u ' : c o n t e n u } ) ,
74 ) ;
75 }
76 }

### 5.5 EcransFlutter.

#### 5.5.1 Ecrandeconnexionscreens/login_screen.dart

Listing11:lib/screens/login_screen.dart
1 i m p o r t ' p a c k a g e : f l u t t e r / m a t e r i a l. d a r t ' ;
2 i m p o r t '.. / s e r v i c e s / a u t h _ s e r v i c e. d a r t ' ;
3 i m p o r t ' h o m e _ s c r e e n. d a r t ' ;
4
5 c l a s s L o g i n S c r e e n e x t e n d s S t a t e f u l W i d g e t {
6 c o n s t L o g i n S c r e e n ( { s u p e r. k e y } ) ;
7 @ o v e r r i d e
8 S t a t e < L o g i n S c r e e n > c r e a t e S t a t e ( ) = > _ L o g i n S c r e e n S t a t e ( ) ;
9 }
10
11 c l a s s _ L o g i n S c r e e n S t a t e e x t e n d s S t a t e < L o g i n S c r e e n > {
12 f i n a l _ e m a i l C t r l = T e x t E d i t i n g C o n t r o l l e r ( ) ;
13 f i n a l _ p a s s w o r d C t r l = T e x t E d i t i n g C o n t r o l l e r ( ) ;
14 f i n a l _ a u t h S e r v i c e = A u t h S e r v i c e ( ) ;
15 b o o l _ l o a d i n g = f a l s e ;
16 S t r i n g? _ e r r e u r ;
17
18 F u t u r e < v o i d > _ l o g i n ( ) a s y n c {
19 s e t S t a t e ( ( ) { _ l o a d i n g = t r u e ; _ e r r e u r = n u l l ; } ) ;
20 f i n a l r e s u l t = a w a i t _ a u t h S e r v i c e. l o g i n (
21 _ e m a i l C t r l. t e x t. t r i m ( ) , _ p a s s w o r d C t r l. t e x t ) ;
22 s e t S t a t e ( ( ) { _ l o a d i n g = f a l s e ; } ) ;
23 i f ( r e s u l t [ ' s u c c e s s ' ] = = t r u e ) {
24 N a v i g a t o r. p u s h R e p l a c e m e n t ( c o n t e x t ,
25 M a t e r i a l P a g e R o u t e ( b u i l d e r : ( _ ) = > c o n s t H o m e S c r e e n ( ) ) )
;
26 } e l s e {
27 s e t S t a t e ( ( ) { _ e r r e u r = r e s u l t [ ' m e s s a g e ' ] ; } ) ;
28 }
29 }
30
31 @ o v e r r i d e
32 W i d g e t b u i l d ( B u i l d C o n t e x t c o n t e x t ) {
33 r e t u r n S c a f f o l d (
34 b a c k g r o u n d C o l o r : c o n s t C o l o r ( 0 x F F 0 0 6 7 4 3 ) ,
35 b o d y : S a f e A r e a (
36 c h i l d : C e n t e r (
37 c h i l d : S i n g l e C h i l d S c r o l l V i e w (
38 p a d d i n g : c o n s t E d g e I n s e t s. a l l ( 2 4 ) ,
39 c h i l d : C a r d (
40 s h a p e : R o u n d e d R e c t a n g l e B o r d e r (


41 b o r d e r R a d i u s : B o r d e r R a d i u s. c i r c u l a r ( 1 6 ) ) ,
42 e l e v a t i o n : 8 ,
43 c h i l d : P a d d i n g (
44 p a d d i n g : c o n s t E d g e I n s e t s. a l l ( 2 8 ) ,
45 c h i l d : C o l u m n (
46 m a i n A x i s S i z e : M a i n A x i s S i z e. m i n ,
47 c h i l d r e n : [
48 / / L o g o / T i t r e
49 c o n s t I c o n ( I c o n s. s u p p o r t _ a g e n t ,
50 c o l o r : C o l o r ( 0 x F F 0 0 6 7 4 3 ) , s i z e : 6 0 ) ,
51 c o n s t S i z e d B o x ( h e i g h t : 1 2 ) ,
52 c o n s t T e x t ( ' G e s t i o n d e s R e c l a m a t i o n s ' ,
53 s t y l e : T e x t S t y l e (
54 f o n t S i z e : 1 8 ,
55 f o n t W e i g h t : F o n t W e i g h t. b o l d ,
56 c o l o r : C o l o r ( 0 x F F 0 0 6 7 4 3 ) ) ) ,
57 c o n s t S i z e d B o x ( h e i g h t : 2 4 ) ,
58 / / C h a m p e m a i l
59 T e x t F i e l d (
60 c o n t r o l l e r : _ e m a i l C t r l ,
61 d e c o r a t i o n : c o n s t I n p u t D e c o r a t i o n (
62 l a b e l T e x t : ' E m a i l ' ,
63 p r e f i x I c o n : I c o n ( I c o n s. e m a i l ) ,
64 b o r d e r : O u t l i n e I n p u t B o r d e r ( ) ,
65 ) ,
66 k e y b o a r d T y p e : T e x t I n p u t T y p e. e m a i l A d d r e s s ,
67 ) ,
68 c o n s t S i z e d B o x ( h e i g h t : 1 6 ) ,
69 / / C h a m p m o t d e p a s s e
70 T e x t F i e l d (
71 c o n t r o l l e r : _ p a s s w o r d C t r l ,
72 o b s c u r e T e x t : t r u e ,
73 d e c o r a t i o n : c o n s t I n p u t D e c o r a t i o n (
74 l a b e l T e x t : ' M o t d e p a s s e ' ,
75 p r e f i x I c o n : I c o n ( I c o n s. l o c k ) ,
76 b o r d e r : O u t l i n e I n p u t B o r d e r ( ) ,
77 ) ,
78 ) ,
79 i f ( _ e r r e u r! = n u l l )... [
80 c o n s t S i z e d B o x ( h e i g h t : 1 0 ) ,
81 T e x t ( _ e r r e u r! ,
82 s t y l e : c o n s t T e x t S t y l e ( c o l o r : C o l o r s.
r e d ) ) ,
83 ] ,
84 c o n s t S i z e d B o x ( h e i g h t : 2 4 ) ,
85 S i z e d B o x (
86 w i d t h : d o u b l e. i n f i n i t y ,
87 c h i l d : E l e v a t e d B u t t o n (
88 o n P r e s s e d : _ l o a d i n g? n u l l : _ l o g i n ,
89 s t y l e : E l e v a t e d B u t t o n. s t y l e F r o m (
90 b a c k g r o u n d C o l o r : c o n s t C o l o r ( 0


x F F 0 0 6 7 4 3 ) ,
91 p a d d i n g :
92 c o n s t E d g e I n s e t s. s y m m e t r i c (
v e r t i c a l : 1 4 ) ,
93 s h a p e : R o u n d e d R e c t a n g l e B o r d e r (
94 b o r d e r R a d i u s : B o r d e r R a d i u s.
c i r c u l a r ( 8 ) ) ,
95 ) ,
96 c h i l d : _ l o a d i n g
97? c o n s t C i r c u l a r P r o g r e s s I n d i c a t o r (
98 c o l o r : C o l o r s. w h i t e )
99 : c o n s t T e x t ( ' S e c o n n e c t e r ' ,
100 s t y l e : T e x t S t y l e (
101 c o l o r : C o l o r s. w h i t e ,
f o n t S i z e : 1 6 ) ) ,
102 ) ,
103 ) ,
104 ] ,
105 ) ,
106 ) ,
107 ) ,
108 ) ,
109 ) ,
110 ) ,
111 ) ;
112 }
113 }

#### 5.5.2 Ecranlistedesticketsscreens/ticket_list_screen.dart

```
Listing12:lib/screens/ticket_list_screen.dart
1 i m p o r t ' p a c k a g e : f l u t t e r / m a t e r i a l. d a r t ' ;
2 i m p o r t '.. / m o d e l s / t i c k e t. d a r t ' ;
3 i m p o r t '.. / s e r v i c e s / t i c k e t _ s e r v i c e. d a r t ' ;
4 i m p o r t '.. / w i d g e t s / t i c k e t _ c a r d. d a r t ' ;
5 i m p o r t ' t i c k e t _ d e t a i l _ s c r e e n. d a r t ' ;
6 i m p o r t ' c r e a t e _ t i c k e t _ s c r e e n. d a r t ' ;
7
8 c l a s s T i c k e t L i s t S c r e e n e x t e n d s S t a t e f u l W i d g e t {
9 c o n s t T i c k e t L i s t S c r e e n ( { s u p e r. k e y } ) ;
10 @ o v e r r i d e
11 S t a t e < T i c k e t L i s t S c r e e n > c r e a t e S t a t e ( ) = >
_ T i c k e t L i s t S c r e e n S t a t e ( ) ;
12 }
13
14 c l a s s _ T i c k e t L i s t S c r e e n S t a t e e x t e n d s S t a t e < T i c k e t L i s t S c r e e n > {
15 f i n a l _ s e r v i c e = T i c k e t S e r v i c e ( ) ;
16 l a t e F u t u r e < L i s t < T i c k e t > > _ f u t u r e T i c k e t s ;
17 S t r i n g? _ f i l t r e S t a t u t ;
18
19 @ o v e r r i d e
20 v o i d i n i t S t a t e ( ) {
```

21 s u p e r. i n i t S t a t e ( ) ;
22 _ c h a r g e r ( ) ;
23 }
24
25 v o i d _ c h a r g e r ( ) {
26 s e t S t a t e ( ( ) {
27 _ f u t u r e T i c k e t s = _ s e r v i c e. l i s t e r T i c k e t s ( s t a t u t :
_ f i l t r e S t a t u t ) ;
28 } ) ;
29 }
30
31 C o l o r _ c o u l e u r S t a t u t ( S t r i n g s t a t u t ) {
32 s w i t c h ( s t a t u t ) {
33 c a s e ' O U V E R T ' : r e t u r n C o l o r s. b l u e ;
34 c a s e ' E N _ C O U R S ' : r e t u r n C o l o r s. o r a n g e ;
35 c a s e ' R E S O L U ' : r e t u r n C o l o r s. g r e e n ;
36 c a s e ' C L O S ' : r e t u r n C o l o r s. g r e y ;
37 d e f a u l t : r e t u r n C o l o r s. b l a c k ;
38 }
39 }
40
41 @ o v e r r i d e
42 W i d g e t b u i l d ( B u i l d C o n t e x t c o n t e x t ) {
43 r e t u r n S c a f f o l d (
44 a p p B a r : A p p B a r (
45 t i t l e : c o n s t T e x t ( ' M e s t i c k e t s ' ) ,
46 b a c k g r o u n d C o l o r : c o n s t C o l o r ( 0 x F F 0 0 6 7 4 3 ) ,
47 f o r e g r o u n d C o l o r : C o l o r s. w h i t e ,
48 a c t i o n s : [
49 P o p u p M e n u B u t t o n < S t r i n g? > (
50 i c o n : c o n s t I c o n ( I c o n s. f i l t e r _ l i s t ) ,
51 o n S e l e c t e d : ( v a l ) {
52 s e t S t a t e ( ( ) { _ f i l t r e S t a t u t = v a l ; } ) ;
53 _ c h a r g e r ( ) ;
54 } ,
55 i t e m B u i l d e r : ( _ ) = > [
56 c o n s t P o p u p M e n u I t e m ( v a l u e : n u l l , c h i l d : T e x t
( ' T o u s ' ) ) ,
57 c o n s t P o p u p M e n u I t e m ( v a l u e : ' O U V E R T ' , c h i l d : T e x t
( ' O u v e r t ' ) ) ,
58 c o n s t P o p u p M e n u I t e m ( v a l u e : ' E N _ C O U R S ' , c h i l d : T e x t
( ' E n c o u r s ' ) ) ,
59 c o n s t P o p u p M e n u I t e m ( v a l u e : ' R E S O L U ' , c h i l d : T e x t
( ' R e s o l u ' ) ) ,
60 c o n s t P o p u p M e n u I t e m ( v a l u e : ' C L O S ' , c h i l d : T e x t
( ' C l o s ' ) ) ,
61 ] ,
62 ) ,
63 ] ,
64 ) ,
65 b o d y : F u t u r e B u i l d e r < L i s t < T i c k e t > > (


```
66 f u t u r e : _ f u t u r e T i c k e t s ,
67 b u i l d e r : ( c o n t e x t , s n a p s h o t ) {
68 i f ( s n a p s h o t. c o n n e c t i o n S t a t e = = C o n n e c t i o n S t a t e.
w a i t i n g ) {
69 r e t u r n c o n s t C e n t e r ( c h i l d : C i r c u l a r P r o g r e s s I n d i c a t o r
( ) ) ;
70 }
71 i f ( s n a p s h o t. h a s E r r o r ) {
72 r e t u r n C e n t e r ( c h i l d : T e x t ( ' E r r e u r : $ { s n a p s h o t. e r r o r
} ' ) ) ;
73 }
74 f i n a l t i c k e t s = s n a p s h o t. d a t a?? [ ] ;
75 i f ( t i c k e t s. i s E m p t y ) {
76 r e t u r n c o n s t C e n t e r ( c h i l d : T e x t ( ' A u c u n t i c k e t t r o u v e
```
. ' ) ) ;
77 }
78 r e t u r n R e f r e s h I n d i c a t o r (
79 o n R e f r e s h : ( ) a s y n c = > _ c h a r g e r ( ) ,
80 c h i l d : L i s t V i e w. b u i l d e r (
81 p a d d i n g : c o n s t E d g e I n s e t s. a l l ( 1 2 ) ,
82 i t e m C o u n t : t i c k e t s. l e n g t h ,
83 i t e m B u i l d e r : ( _ , i ) = > T i c k e t C a r d (
84 t i c k e t : t i c k e t s [ i ] ,
85 o n T a p : ( ) = > N a v i g a t o r. p u s h (
86 c o n t e x t ,
87 M a t e r i a l P a g e R o u t e (
88 b u i l d e r : ( _ ) = >
89 T i c k e t D e t a i l S c r e e n ( t i c k e t I d : t i c k e t s [ i ].
i d ) ,
90 ) ,
91 ). t h e n ( ( _ ) = > _ c h a r g e r ( ) ) ,
92 ) ,
93 ) ,
94 ) ;
95 } ,
96 ) ,
97 f l o a t i n g A c t i o n B u t t o n : F l o a t i n g A c t i o n B u t t o n. e x t e n d e d (
98 o n P r e s s e d : ( ) = > N a v i g a t o r. p u s h (
99 c o n t e x t ,
100 M a t e r i a l P a g e R o u t e ( b u i l d e r : ( _ ) = > c o n s t
C r e a t e T i c k e t S c r e e n ( ) ) ,
101 ). t h e n ( ( _ ) = > _ c h a r g e r ( ) ) ,
102 l a b e l : c o n s t T e x t ( ' N o u v e a u t i c k e t ' ) ,
103 i c o n : c o n s t I c o n ( I c o n s. a d d ) ,
104 b a c k g r o u n d C o l o r : c o n s t C o l o r ( 0 x F F 0 0 6 7 4 3 ) ,
105 ) ,
106 ) ;
107 }
108 }

#### 5.5.3 WidgetTicketCardwidgets/ticket_card.dart


Listing13:lib/widgets/ticket_card.dart
1 i m p o r t ' p a c k a g e : f l u t t e r / m a t e r i a l. d a r t ' ;
2 i m p o r t '.. / m o d e l s / t i c k e t. d a r t ' ;
3
4 c l a s s T i c k e t C a r d e x t e n d s S t a t e l e s s W i d g e t {
5 f i n a l T i c k e t t i c k e t ;
6 f i n a l V o i d C a l l b a c k o n T a p ;
7
8 c o n s t T i c k e t C a r d ( { s u p e r. k e y , r e q u i r e d t h i s. t i c k e t ,
9 r e q u i r e d t h i s. o n T a p } ) ;
10
11 C o l o r g e t _ s t a t C o l o r {
12 s w i t c h ( t i c k e t. s t a t u t ) {
13 c a s e ' O U V E R T ' : r e t u r n C o l o r s. b l u e. s h a d e 7 0 0 ;
14 c a s e ' E N _ C O U R S ' : r e t u r n C o l o r s. o r a n g e. s h a d e 7 0 0 ;
15 c a s e ' R E S O L U ' : r e t u r n C o l o r s. g r e e n. s h a d e 7 0 0 ;
16 c a s e ' C L O S ' : r e t u r n C o l o r s. g r e y. s h a d e 6 0 0 ;
17 d e f a u l t : r e t u r n C o l o r s. b l a c k ;
18 }
19 }
20
21 C o l o r g e t _ p r i o C o l o r {
22 s w i t c h ( t i c k e t. p r i o r i t e ) {
23 c a s e ' C R I T I Q U E ' : r e t u r n C o l o r s. r e d. s h a d e 7 0 0 ;
24 c a s e ' H A U T E ' : r e t u r n C o l o r s. o r a n g e. s h a d e 7 0 0 ;
25 c a s e ' N O R M A L E ' : r e t u r n C o l o r s. b l u e. s h a d e 7 0 0 ;
26 c a s e ' B A S S E ' : r e t u r n C o l o r s. g r e e n. s h a d e 7 0 0 ;
27 d e f a u l t : r e t u r n C o l o r s. g r e y ;
28 }
29 }
30
31 @ o v e r r i d e
32 W i d g e t b u i l d ( B u i l d C o n t e x t c o n t e x t ) {
33 r e t u r n C a r d (
34 m a r g i n : c o n s t E d g e I n s e t s. o n l y ( b o t t o m : 1 0 ) ,
35 e l e v a t i o n : 3 ,
36 s h a p e : R o u n d e d R e c t a n g l e B o r d e r (
37 b o r d e r R a d i u s : B o r d e r R a d i u s. c i r c u l a r ( 1 0 ) ) ,
38 c h i l d : I n k W e l l (
39 b o r d e r R a d i u s : B o r d e r R a d i u s. c i r c u l a r ( 1 0 ) ,
40 o n T a p : o n T a p ,
41 c h i l d : P a d d i n g (
42 p a d d i n g : c o n s t E d g e I n s e t s. a l l ( 1 4 ) ,
43 c h i l d : C o l u m n (
44 c r o s s A x i s A l i g n m e n t : C r o s s A x i s A l i g n m e n t. s t a r t ,
45 c h i l d r e n : [
46 R o w (
47 m a i n A x i s A l i g n m e n t : M a i n A x i s A l i g n m e n t.
s p a c e B e t w e e n ,
48 c h i l d r e n : [
49 E x p a n d e d (


50 c h i l d : T e x t ( t i c k e t. t i t r e ,
51 s t y l e : c o n s t T e x t S t y l e (
52 f o n t W e i g h t : F o n t W e i g h t. b o l d ,
f o n t S i z e : 1 5 ) ,
53 o v e r f l o w : T e x t O v e r f l o w. e l l i p s i s ) ,
54 ) ,
55 C o n t a i n e r (
56 p a d d i n g : c o n s t E d g e I n s e t s. s y m m e t r i c (
57 h o r i z o n t a l : 8 , v e r t i c a l : 3 ) ,
58 d e c o r a t i o n : B o x D e c o r a t i o n (
59 c o l o r : _ s t a t C o l o r. w i t h O p a c i t y ( 0. 1 2 ) ,
60 b o r d e r R a d i u s : B o r d e r R a d i u s. c i r c u l a r ( 1 2 ) ,
61 b o r d e r : B o r d e r. a l l ( c o l o r : _ s t a t C o l o r ) ) ,
62 c h i l d : T e x t ( t i c k e t. s t a t u t ,
63 s t y l e : T e x t S t y l e (
64 c o l o r : _ s t a t C o l o r ,
65 f o n t S i z e : 1 1 ,
66 f o n t W e i g h t : F o n t W e i g h t. w 6 0 0 ) ) ,
67 ) ,
68 ] ,
69 ) ,
70 c o n s t S i z e d B o x ( h e i g h t : 6 ) ,
71 T e x t ( t i c k e t. d e s c r i p t i o n ,
72 m a x L i n e s : 2 ,
73 o v e r f l o w : T e x t O v e r f l o w. e l l i p s i s ,
74 s t y l e : c o n s t T e x t S t y l e (
75 c o l o r : C o l o r s. b l a c k 5 4 , f o n t S i z e : 1 3 ) ) ,
76 c o n s t S i z e d B o x ( h e i g h t : 8 ) ,
77 R o w ( c h i l d r e n : [
78 I c o n ( I c o n s. f l a g , s i z e : 1 4 , c o l o r : _ p r i o C o l o r ) ,
79 c o n s t S i z e d B o x ( w i d t h : 4 ) ,
80 T e x t ( t i c k e t. p r i o r i t e ,
81 s t y l e : T e x t S t y l e (
82 c o l o r : _ p r i o C o l o r , f o n t S i z e : 1 2 ) ) ,
83 c o n s t S p a c e r ( ) ,
84 c o n s t I c o n ( I c o n s. p e r s o n _ o u t l i n e ,
85 s i z e : 1 4 , c o l o r : C o l o r s. g r e y ) ,
86 c o n s t S i z e d B o x ( w i d t h : 4 ) ,
87 T e x t ( t i c k e t. a u t e u r N o m ,
88 s t y l e : c o n s t T e x t S t y l e (
89 c o l o r : C o l o r s. g r e y , f o n t S i z e : 1 2 ) ) ,
90 ] ) ,
91 ] ,
92 ) ,
93 ) ,
94 ) ,
95 ) ;
96 }
97 }

### 5.6 Ecrandecreationd'unticket


Listing14: lib/screens/create_ticket_screen.dart
1 i m p o r t ' p a c k a g e : f l u t t e r / m a t e r i a l. d a r t ' ;
2 i m p o r t '.. / s e r v i c e s / t i c k e t _ s e r v i c e. d a r t ' ;
3
4 c l a s s C r e a t e T i c k e t S c r e e n e x t e n d s S t a t e f u l W i d g e t {
5 c o n s t C r e a t e T i c k e t S c r e e n ( { s u p e r. k e y } ) ;
6 @ o v e r r i d e
7 S t a t e < C r e a t e T i c k e t S c r e e n > c r e a t e S t a t e ( ) = >
_ C r e a t e T i c k e t S c r e e n S t a t e ( ) ;
8 }
9
10 c l a s s _ C r e a t e T i c k e t S c r e e n S t a t e e x t e n d s S t a t e < C r e a t e T i c k e t S c r e e n >
{
11 f i n a l _ f o r m K e y = G l o b a l K e y < F o r m S t a t e > ( ) ;
12 f i n a l _ t i t r e C t r l = T e x t E d i t i n g C o n t r o l l e r ( ) ;
13 f i n a l _ d e s c C t r l = T e x t E d i t i n g C o n t r o l l e r ( ) ;
14 S t r i n g _ t y p e = ' I N C I D E N T ' ;
15 S t r i n g _ p r i o r i t e = ' N O R M A L E ' ;
16 b o o l _ l o a d i n g = f a l s e ;
17 f i n a l _ s e r v i c e = T i c k e t S e r v i c e ( ) ;
18
19 s t a t i c c o n s t _ t y p e s = [
20 ' I N C I D E N T ' , ' R E C L A M A T I O N ' , ' D E M A N D E '
21 ] ;
22 s t a t i c c o n s t _ p r i o r i t e s = [
23 ' B A S S E ' , ' N O R M A L E ' , ' H A U T E ' , ' C R I T I Q U E '
24 ] ;
25
26 F u t u r e < v o i d > _ s o u m e t t r e ( ) a s y n c {
27 i f (! _ f o r m K e y. c u r r e n t S t a t e!. v a l i d a t e ( ) ) r e t u r n ;
28 s e t S t a t e ( ( ) = > _ l o a d i n g = t r u e ) ;
29 t r y {
30 a w a i t _ s e r v i c e. c r e e r T i c k e t ( {
31 ' t i t r e ' : _ t i t r e C t r l. t e x t. t r i m ( ) ,
32 ' d e s c r i p t i o n ' : _ d e s c C t r l. t e x t. t r i m ( ) ,
33 ' t y p e _ t i c k e t ' : _ t y p e ,
34 ' p r i o r i t e ' : _ p r i o r i t e ,
35 } ) ;
36 i f ( m o u n t e d ) {
37 S c a f f o l d M e s s e n g e r. o f ( c o n t e x t ). s h o w S n a c k B a r (
38 c o n s t S n a c k B a r (
39 c o n t e n t : T e x t ( ' T i c k e t c r e e a v e c s u c c e s! ' ) ,
40 b a c k g r o u n d C o l o r : C o l o r s. g r e e n ) ,
41 ) ;
42 N a v i g a t o r. p o p ( c o n t e x t ) ;
43 }
44 } c a t c h ( e ) {
45 S c a f f o l d M e s s e n g e r. o f ( c o n t e x t ). s h o w S n a c k B a r (
46 S n a c k B a r ( c o n t e n t : T e x t ( ' E r r e u r : $ e ' ) ,
47 b a c k g r o u n d C o l o r : C o l o r s. r e d ) ) ;
48 } f i n a l l y {


49 s e t S t a t e ( ( ) = > _ l o a d i n g = f a l s e ) ;
50 }
51 }
52
53 @ o v e r r i d e
54 W i d g e t b u i l d ( B u i l d C o n t e x t c o n t e x t ) {
55 r e t u r n S c a f f o l d (
56 a p p B a r : A p p B a r (
57 t i t l e : c o n s t T e x t ( ' N o u v e a u t i c k e t ' ) ,
58 b a c k g r o u n d C o l o r : c o n s t C o l o r ( 0 x F F 0 0 6 7 4 3 ) ,
59 f o r e g r o u n d C o l o r : C o l o r s. w h i t e ,
60 ) ,
61 b o d y : S i n g l e C h i l d S c r o l l V i e w (
62 p a d d i n g : c o n s t E d g e I n s e t s. a l l ( 2 0 ) ,
63 c h i l d : F o r m (
64 k e y : _ f o r m K e y ,
65 c h i l d : C o l u m n (
66 c r o s s A x i s A l i g n m e n t : C r o s s A x i s A l i g n m e n t. s t r e t c h ,
67 c h i l d r e n : [
68 T e x t F o r m F i e l d (
69 c o n t r o l l e r : _ t i t r e C t r l ,
70 d e c o r a t i o n : c o n s t I n p u t D e c o r a t i o n (
71 l a b e l T e x t : ' T i t r e * ' ,
72 b o r d e r : O u t l i n e I n p u t B o r d e r ( ) ,
73 p r e f i x I c o n : I c o n ( I c o n s. t i t l e ) ,
74 ) ,
75 v a l i d a t o r : ( v ) = >
76 ( v = = n u l l | | v. i s E m p t y )? ' C h a m p
o b l i g a t o i r e ' : n u l l ,
77 ) ,
78 c o n s t S i z e d B o x ( h e i g h t : 1 6 ) ,
79 T e x t F o r m F i e l d (
80 c o n t r o l l e r : _ d e s c C t r l ,
81 m a x L i n e s : 4 ,
82 d e c o r a t i o n : c o n s t I n p u t D e c o r a t i o n (
83 l a b e l T e x t : ' D e s c r i p t i o n * ' ,
84 b o r d e r : O u t l i n e I n p u t B o r d e r ( ) ,
85 p r e f i x I c o n : I c o n ( I c o n s. d e s c r i p t i o n ) ,
86 a l i g n L a b e l W i t h H i n t : t r u e ,
87 ) ,
88 v a l i d a t o r : ( v ) = >
89 ( v = = n u l l | | v. i s E m p t y )? ' C h a m p
o b l i g a t o i r e ' : n u l l ,
90 ) ,
91 c o n s t S i z e d B o x ( h e i g h t : 1 6 ) ,
92 D r o p d o w n B u t t o n F o r m F i e l d < S t r i n g > (
93 v a l u e : _ t y p e ,
94 d e c o r a t i o n : c o n s t I n p u t D e c o r a t i o n (
95 l a b e l T e x t : ' T y p e d e t i c k e t ' ,
96 b o r d e r : O u t l i n e I n p u t B o r d e r ( ) ,
97 p r e f i x I c o n : I c o n ( I c o n s. c a t e g o r y ) ,


98 ) ,
99 i t e m s : _ t y p e s. m a p ( ( t ) = >
100 D r o p d o w n M e n u I t e m ( v a l u e : t , c h i l d : T e x t ( t ) ) ).
t o L i s t ( ) ,
101 o n C h a n g e d : ( v ) = > s e t S t a t e ( ( ) = > _ t y p e = v! ) ,
102 ) ,
103 c o n s t S i z e d B o x ( h e i g h t : 1 6 ) ,
104 D r o p d o w n B u t t o n F o r m F i e l d < S t r i n g > (
105 v a l u e : _ p r i o r i t e ,
106 d e c o r a t i o n : c o n s t I n p u t D e c o r a t i o n (
107 l a b e l T e x t : ' P r i o r i t e ' ,
108 b o r d e r : O u t l i n e I n p u t B o r d e r ( ) ,
109 p r e f i x I c o n : I c o n ( I c o n s. f l a g ) ,
110 ) ,
111 i t e m s : _ p r i o r i t e s. m a p ( ( p ) = >
112 D r o p d o w n M e n u I t e m ( v a l u e : p , c h i l d : T e x t ( p ) ) ).
t o L i s t ( ) ,
113 o n C h a n g e d : ( v ) = > s e t S t a t e ( ( ) = > _ p r i o r i t e = v! )
,
114 ) ,
115 c o n s t S i z e d B o x ( h e i g h t : 2 8 ) ,
116 E l e v a t e d B u t t o n. i c o n (
117 o n P r e s s e d : _ l o a d i n g? n u l l : _ s o u m e t t r e ,
118 i c o n : _ l o a d i n g
119? c o n s t S i z e d B o x (
120 w i d t h : 1 8 , h e i g h t : 1 8 ,
121 c h i l d : C i r c u l a r P r o g r e s s I n d i c a t o r (
122 c o l o r : C o l o r s. w h i t e , s t r o k e W i d t h : 2 )
)
123 : c o n s t I c o n ( I c o n s. s e n d , c o l o r : C o l o r s. w h i t e
) ,
124 l a b e l : T e x t (
125 _ l o a d i n g? ' E n v o i... ' : ' S o u m e t t r e l e t i c k e t
' ,
126 s t y l e : c o n s t T e x t S t y l e (
127 c o l o r : C o l o r s. w h i t e , f o n t S i z e : 1 6 ) ) ,
128 s t y l e : E l e v a t e d B u t t o n. s t y l e F r o m (
129 b a c k g r o u n d C o l o r : c o n s t C o l o r ( 0 x F F 0 0 6 7 4 3 ) ,
130 p a d d i n g : c o n s t E d g e I n s e t s. s y m m e t r i c ( v e r t i c a l :
1 4 ) ,
131 s h a p e : R o u n d e d R e c t a n g l e B o r d e r (
132 b o r d e r R a d i u s : B o r d e r R a d i u s. c i r c u l a r ( 8 ) ) ,
133 ) ,
134 ) ,
135 ] ,
136 ) ,
137 ) ,
138 ) ,
139 ) ;
140 }
141 }


## 6 Phase 4 Integration,TestsetValidation

```
Phase 4 Integration,TestsetValidation
```
```
Cettedernierephasevalidel'ensemble del'integrationentrele backend Djangoet
l'applicationFlutter. Chaqueetudiant/group edoittesterlesscenariosci-dessouset
consignerlesresultats.
```
### 6.1 Scenariosdetestsavalider.

```
TravauxPratiques:Scenariosdetestsd'integration
```
```
Test1. Authentication: UncitoyenseconnectedepuisFlutteravecsesiden-
tiantsDjango.L'accesstokeneststo ckedansSharedPreferences. Verier
quelesrequetessuivantesp ortentleb onheaderAuthorization.
```
```
Test2. Creationdeticket:L'utilisateurremplitleformulaireFlutteretsoumet
unticket.Verierdansl'interfaceDjangoAdminqueleticketestbiencree
avecleb onauteur.
```
```
Test3. Listedesticketsavecltre: AppliquerunltreparstatutdansFlutter
et verierque lesparametres sontbien envoyes dans la querystring de
l'API.
```
```
Test4. Changementdestatut: Untechnicienchangelestatutd'unticketen
EN_COURS.Verierquel'historiqueesta jouteetquelecitoyenvoitlenou-
veaustatut.
```
```
Test5. Privileges: Uncitoyenessaied'app eler/changer_statut/. Verierque
l'APIrenvoieunco de403 Forbidden.
```
```
Test6. Token expire : Attendre l'expiration du token d'acces (mo dier
ACCESS_TOKEN_LIFETIMEa 1 minutep ourletest).Verierquel'application
gerelare-connexionoulerefreshautomatiquement.
```
### 6.2 Bonnespratiquesdesecurite

```
Bonnepratique
```
```
X Nejamaissto ckerlemotdepasseenclairdansl'applicationmobile.
```
```
X UtiliserHTTPSenpro duction(congurernginx+Certbot).
```
```
X Restreindre CORS_ALLOW_ALL_ORIGINS = Falseen pro ductionet lister unique-
mentlesoriginesautorisees.
```
```
X ViderSharedPreferenceslorsdulogout(token+donneesutilisateur).
```

```
X Validerlesdonneescoteserveur(Django)etcoteclient(Flutter)nejamaissup-
p oserqueleclientestdeconance.
```
### 6.3 GestiondeserreursdansFlutter.

Listing15:Gestiondesco desHTTPdansApiService
1 F u t u r e < d y n a m i c > _ h a n d l e R e s p o n s e ( h t t p. R e s p o n s e r e s p o n s e ) {
2 s w i t c h ( r e s p o n s e. s t a t u s C o d e ) {
3 c a s e 2 0 0 :
4 c a s e 2 0 1 :
5 r e t u r n F u t u r e. v a l u e ( j s o n D e c o d e ( r e s p o n s e. b o d y ) ) ;
6 c a s e 4 0 0 :
7 t h r o w E x c e p t i o n ( ' D o n n e e s i n v a l i d e s : $ { r e s p o n s e. b o d y } ' ) ;
8 c a s e 4 0 1 :
9 t h r o w E x c e p t i o n ( ' N o n a u t h e n t i f i e. V e u i l l e z v o u s
r e c o n n e c t e r. ' ) ;
10 c a s e 4 0 3 :
11 t h r o w E x c e p t i o n ( ' A c c e s r e f u s e. D r o i t s i n s u f f i s a n t s. ' ) ;
12 c a s e 4 0 4 :
13 t h r o w E x c e p t i o n ( ' R e s s o u r c e i n t r o u v a b l e. ' ) ;
14 c a s e 5 0 0 :
15 t h r o w E x c e p t i o n ( ' E r r e u r s e r v e u r. R e e s s a y e z p l u s t a r d. ' ) ;
16 d e f a u l t :
17 t h r o w E x c e p t i o n (
18 ' E r r e u r i n a t t e n d u e : $ { r e s p o n s e. s t a t u s C o d e } ' ) ;
19 }
20 }

## 7 LivrablesetCriteresd'Evaluation

### 7.1 Livrablesattendus

```
Livrablesattendus
```
```
L1.Do cumentsdeconception(Phase1):
```
```
− Diagrammedecasd'utilisation.
− DiagrammedeclassesUML.
− Diagrammedesequences(creationd'unticket).
```
```
L2.Co desourcedubackendDjango(Phase2):
```
```
− Mo delesCustomUser,Ticket,Commentaire,HistoriqueStatut.
− Serializers,ViewSets,Permissions.
− AuthenticationJWTfonctionnelle.
```

```
− Fichierrequirements.txtajour.
```
```
L3.Co desourcedel'applicationFlutter(Phase3):
```
```
− Ecrandeconnexion.
− Listeetdetaildestickets.
− Formulairedecreationdeticket.
− GestiondutokenJWT(sto ckage+injection).
```
```
L4.Rapp ortdetests(Phase4):
```
```
− Resultatsdes 6 scenariosdetestsd'integration.
− Capturesd'ecranouenregistrementsvideo.
```
```
L5.(Bonus)Fonctionnalitesavancees:
```
```
− Tableaudeb ordadminavecstatistiques(nombredeticketsparstatut,par
technicien).
− Noticationslo calesFlutterlorsduchangementdestatut.
− Recherchedanslalistedestickets.
− APKAndroidgenereavec flutter build apk.
```
### 7.2 Grilled'evaluation

```
Critere Points Details
Conception (diagrammes
UML)
```
```
4 pts Correction,completude,lisibilite
```
```
Mo deles Django + Mi-
grations
```
```
3 pts Relations,choixdechamps,contraintes
```
```
API REST DRF (end-
p oints,serializers)
```
```
4 pts Fonctionnalite,resp ectdesconventionsREST
```
```
AuthenticationJWT 2 pts Login,refresh,protectiondesroutes
Permissionsetroles 2 pts Citoyen/Technicien/Admin
Application Flutter 
Auth
```
```
2 pts Login,sto ckagetoken,logout
```
```
Application Flutter 
Tickets
```
```
4 pts Liste,ltres,detail,creation
```
```
Integrationettests 3 pts Scenariospasses,gestionerreurs
Qualiteduco de 2 pts Lisibilite,organisation,commentaires
Bonus (tableau de b ord,
APK... )
```
```
+4pts Sousreservedureste
```
```
TOTAL 26 pts
```
7.3. Criteresdereussitedupro jet


I Accessibilite et simplicite: l'interfaceFlutterdoitetreutilisableparuncitoyen
sansformationprealable.

I Tauxderesolution:leworkowdegestiondestickets(OUVERT→EN_COURS
→RESOLU→CLOS)doitetrecompletementop erationnel.

I Reductiondu tempsdetraitement: lesystemed'attributionetdepriorisation
doitetrefonctionnel.

I Securite:aucuneroutesensiblenedoitetreaccessiblesansauthenticationvalide.

I Integration reelle: l'applicationFlutterdoitcommuniqueravecl'APIDjangoen
tempsreel(pasdedonneesendurdansleco de).

```
Attention
```
```
Toutplagiatoucopiedeco deentregroup esentraineraautomatiquementlanotede
0/26p ourlespartiesconcernees. Leco dedoitetreentierementecritparlegroup e.
L'utilisationdelado cumentationocielleDjango,Flutter,etDRFestautoriseeet
encouragee.
```
## 8 RessourcesetAide-Memoire

### 8.1 CommandesutilesDjango

```
# C r e e r l e s m i g r a t i o n s
p y t h o n m a n a g e. p y
m a k e m i g r a t i o n s
```
```
# A p p l i q u e r l e s m i g r a t i o n s
p y t h o n m a n a g e. p y m i g r a t e
```
```
# L a n c e r l e s e r v e u r
p y t h o n m a n a g e. p y r u n s e r v e r
```
```
# C r e e r u n s u p e r u s e r
p y t h o n m a n a g e. p y
c r e a t e s u p e r u s e r
```
```
# S h e l l i n t e r a c t i f
p y t h o n m a n a g e. p y s h e l l
```
```
# T e s t s
p y t h o n m a n a g e. p y t e s t
```
### 8.2 CommandesutilesFlutter

```
# C r e e r l e p r o j e t
f l u t t e r c r e a t e
r e c l a m a t i o n s _ a p p
```
```
# I n s t a l l e r l e s p a c k a g e s
f l u t t e r p u b g e t
```
```
# L a n c e r s u r e m u l a t e u r
f l u t t e r r u n
```
```
# C o m p i l e r A P K
f l u t t e r b u i l d a p k - - r e l e a s e
```
```
# I n s p e c t e r l e s l o g s
f l u t t e r l o g s
```
```
# N e t t o y e r l e c a c h e
f l u t t e r c l e a n
```

### 8.3 Adressesutilesendevelopp ement

```
Contexte URL
EmulateurAndroid→lo calhost http://10.0.2.2:8000
iOSSimulator→lo calhost http://127.0.0.1:8000
Appareilphysique(memereseauWi) http://<IP machine>:8000
InterfaceDjangoAdmin http://127.0.0.1:8000/admin/
Do cumentationAPI(DRFBrowsableAPI) http://127.0.0.1:8000/api/
```
```
Bonnepratique
```
```
Pour connaitre l'adresse IP de votre machine sous Linux, utilisez la commande
ip addr show ou hostname -I.SousWindows,utilisez ipconfig.
```
### 8.4 Do cumentationocielle

. Django: https://docs.djangoproject.com/
. DjangoRESTFramework: https://www.django- rest- framework.org/
. SimpleJWT:https://django- rest- framework- simplejwt.readthedocs.io/
. Flutter: https://docs.flutter.dev/
. Packagehttp(Dart): https://pub.dev/packages/http
. SharedPreferences:https://pub.dev/packages/shared_preferences
. Provider(gestiond'etat):https://pub.dev/packages/provider

## Bonnechance atous!

```
First,solvetheproblem. Then,writethecode.
JohnJohnson
```
```
RenduviaGitHub:
https://github.com/lawsonlatevisena
```

