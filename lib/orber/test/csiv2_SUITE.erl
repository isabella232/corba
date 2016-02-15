%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2005-2013. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%
%%

-module(csiv2_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("orber/include/corba.hrl").
-include_lib("orber/COSS/CosNaming/CosNaming.hrl").
-include_lib("orber/src/orber_iiop.hrl").
-include_lib("orber/src/ifr_objects.hrl").
-include("idl_output/orber_test_server.hrl").
-include_lib("orber/COSS/CosNaming/CosNaming_NamingContextExt.hrl").
-include_lib("orber/COSS/CosNaming/CosNaming_NamingContext.hrl").
%%-include_lib("orber/src/OrberCSIv2.hrl").

-define(default_timeout, ?t:minutes(5)).

-define(match(ExpectedRes,Expr),
	fun() ->
	       AcTuAlReS = (catch (Expr)),
	       case AcTuAlReS of
		   ExpectedRes ->
		       io:format("------ CORRECT RESULT ------~n~p~n",
				 [AcTuAlReS]),
		       AcTuAlReS;
		   _ ->
		       io:format("###### ERROR ERROR ######~nRESULT:  ~p~n",
				 [AcTuAlReS]),
		       ?line exit(AcTuAlReS)
	       end
       end()).

-define(REQUEST_ID, 0).

-define(REPLY_FRAG_1, <<71,73,79,80,1,2,2,1,0,0,0,41,0,0,0,?REQUEST_ID,0,0,0,0,0,0,0,1,78,69,79,0,0,0,0,2,0,10,0,0,0,0,0,0,0,0,0,18,0,0,0,0,0,0,0,4,49>>).
%% The fragments are identical for requests and replies.
-define(FRAG_2, <<71,73,79,80,1,2,2,7,0,0,0,5,0,0,0,?REQUEST_ID,50>>).
-define(FRAG_3, <<71,73,79,80,1,2,2,7,0,0,0,5,0,0,0,?REQUEST_ID,51>>).
-define(FRAG_4, <<71,73,79,80,1,2,0,7,0,0,0,5,0,0,0,?REQUEST_ID,0>>).

%% Should X509 DER generated by, for example, OpenSSL
-define(X509DER,
	<<42>>).

%% Should X509 PEM generated by, for example, OpenSSL
-define(X509PEM,
	<<42>>).

%% IOR exported by VB (CSIv2 activated).
-define(VB_IOR,
	#'IOP_IOR'
	{type_id = "IDL:omg.org/CosNotifyComm/SequencePushConsumer:1.0",
	 profiles =
	 [#'IOP_TaggedProfile'
	  {tag = ?TAG_INTERNET_IOP,
	   profile_data =
	   #'IIOP_ProfileBody_1_1'{
	     iiop_version = #'IIOP_Version'{major = 1,
					    minor = 2},
	     host =  "127.0.0.1",
	     port = 0,
	     object_key = [0,86,66,1,0,0,0,24,47,70,77,65,95,67,73,82,80,77,65,78,95,80,79,65,95,83,69,67,85,82,69,0,0,0,0,4,0,0,4,186,0,0,2,10,81,218,65,185],
	     components =
	     [#'IOP_TaggedComponent'{tag = ?TAG_SSL_SEC_TRANS,
				     component_data = #'SSLIOP_SSL'{
				       target_supports = 102,
				       target_requires = 66,
				       port = 49934}},
	      #'IOP_TaggedComponent'{tag = ?TAG_CSI_SEC_MECH_LIST,
				     component_data =
	      #'CSIIOP_CompoundSecMechList'{stateful = true,
					    mechanism_list =
					    [#'CSIIOP_CompoundSecMech'
					     {target_requires = 66,
					      transport_mech = #'IOP_TaggedComponent'{
						tag = ?TAG_TLS_SEC_TRANS,
						component_data =
						#'CSIIOP_TLS_SEC_TRANS'{
						  target_supports = 102,
						  target_requires = 66,
						  addresses =
						  [#'CSIIOP_TransportAddress'
						   {host_name = "127.0.0.1",
						    port = 49934}]}},
					      as_context_mech =
					      #'CSIIOP_AS_ContextSec'{
						target_supports = 0,
						target_requires = 0,
						client_authentication_mech = [],
						target_name = []},
					      sas_context_mech =
					      #'CSIIOP_SAS_ContextSec'{
						target_supports = 1024,
						target_requires = 0,
						privilege_authorities =
						[#'CSIIOP_ServiceConfiguration'
						 {syntax = 1447174401,
						  name = "Borland"}],
						supported_naming_mechanisms = [[6,
										6,
										103,
										129,
										2,
										1,
										1,
										1]],
						supported_identity_types = 15}}]}},
	      #'IOP_TaggedComponent'
	      {tag = ?TAG_CODE_SETS,
	       component_data =
	       #'CONV_FRAME_CodeSetComponentInfo'{'ForCharData' =
						  #'CONV_FRAME_CodeSetComponent'{
						    native_code_set = 65537,
						    conversion_code_sets = [83951617]},
						  'ForWcharData' =
						  #'CONV_FRAME_CodeSetComponent'{
						   native_code_set = 65801,
						    conversion_code_sets = []}}},
	      #'IOP_TaggedComponent'{tag = ?TAG_ORB_TYPE,
				     component_data = 1447645952},
	      #'IOP_TaggedComponent'{tag = 1447645955,
				     component_data = [0,5,7,1,127]}]}}]}).

%% Common basic types
-define(OID, {2,23,130,1,1,1}).

-define(OCTET_STR, [1,2,3,4]).

-define(BIT_STR, [0,1,0,1,1]).

-define(BOOLEAN, false).

-define(ANY, [19,5,111,116,112,67,65]).

-ifdef(false).
%% PKIX1Explicit88
-define(AlgorithmIdentifier,
	#'AlgorithmIdentifier'{algorithm = ?OID,
			       parameters = ?ANY}).

-define(Validity, #'Validity'{notBefore = {utcTime, "19820102070533.8"},
			      notAfter = {generalTime, "19820102070533.8"}}).

-define(SubjectPublicKeyInfo,
	#'SubjectPublicKeyInfo'{algorithm = ?AlgorithmIdentifier,
				subjectPublicKey = ?BIT_STR}).

-define(AttributeTypeAndValue,
	#'AttributeTypeAndValue'{type = ?OID,
				 value = <<19,11,69,114,105,99,115,115,111,110,32,65,66>>}).

-define(RelativeDistinguishedName, [?AttributeTypeAndValue]).

-define(RDNSequence, [?RelativeDistinguishedName]).

-define(Name, {rdnSequence, ?RDNSequence}).

-define(Version, v3).

-define(CertificateSerialNumber, 1).

-define(UniqueIdentifier, ?BIT_STR).

-define(Extension, #'Extension'{extnID = ?OID,
				critical = ?BOOLEAN,
				extnValue = ?OCTET_STR}).

-define(Extensions, [?Extension]).

-define(TBSCertificate,
	#'TBSCertificate'{version = ?Version,
			  serialNumber = ?CertificateSerialNumber,
			  signature = ?AlgorithmIdentifier,
			  issuer = ?Name,
			  validity = ?Validity,
			  subject = ?Name,
			  subjectPublicKeyInfo = ?SubjectPublicKeyInfo,
			  issuerUniqueID = ?UniqueIdentifier,
			  subjectUniqueID = ?UniqueIdentifier,
			  extensions = ?Extensions}).

-define(Certificate, #'Certificate'{tbsCertificate = ?TBSCertificate,
				    signatureAlgorithm = ?AlgorithmIdentifier,
				    signature = ?BIT_STR}).

%% PKIX1Implicit88

-define(GeneralName, {registeredID, ?OID}).

-define(GeneralNames, [?GeneralName]).

%% PKIXAttributeCertificate
-define(AttCertValidityPeriod,
	#'AttCertValidityPeriod'{notBeforeTime = "19820102070533.8",
				 notAfterTime = "19820102070533.8"}).


-define(Attribute, #'Attribute'{type = ?OID,
				values = []}).

-define(Attributes, [?Attribute]).

-define(IssuerSerial, #'IssuerSerial'{issuer = ?GeneralNames,
				      serial = ?CertificateSerialNumber,
				      issuerUID = ?UniqueIdentifier}).

-define(DigestedObjectType, publicKey). %% Enum

-define(ObjectDigestInfo,
	#'ObjectDigestInfo'{digestedObjectType = ?DigestedObjectType,
			    otherObjectTypeID = ?OID,
			    digestAlgorithm = ?AlgorithmIdentifier,
			    objectDigest = ?BIT_STR}).

-define(V2Form, #'V2Form'{issuerName = ?GeneralNames,
			  baseCertificateID = ?IssuerSerial,
			  objectDigestInfo = ?ObjectDigestInfo}).

-define(AttCertVersion, v2).

-define(Holder, #'Holder'{baseCertificateID = ?IssuerSerial,
			  entityName = ?GeneralNames,
			  objectDigestInfo = ?ObjectDigestInfo}).

-define(AttCertIssuer, {v2Form, ?V2Form}).

-define(AttributeCertificateInfo,
	#'AttributeCertificateInfo'{version = ?AttCertVersion,
				    holder = ?Holder,
				    issuer = ?AttCertIssuer,
				    signature = ?AlgorithmIdentifier,
				    serialNumber = ?CertificateSerialNumber,
				    attrCertValidityPeriod = ?AttCertValidityPeriod,
				    attributes = ?Attributes,
				    issuerUniqueID = ?UniqueIdentifier,
				    extensions = ?Extensions}).

-define(AttributeCertificate,
	#'AttributeCertificate'{acinfo = ?AttributeCertificateInfo,
				signatureAlgorithm = ?AlgorithmIdentifier,
				signatureValue = ?BIT_STR}).


%% OrberCSIv2
-define(AttributeCertChain,
	#'AttributeCertChain'{attributeCert = ?AttributeCertificate,
			      certificateChain = ?CertificateChain}).

-define(CertificateChain, [?Certificate]).

-define(VerifyingCertChain, [?Certificate]).

-endif.

%%-----------------------------------------------------------------
%% External exports
%%-----------------------------------------------------------------
-export([all/0, suite/0,groups/0,init_per_group/2,end_per_group/2, cases/0,
	 init_per_suite/1, end_per_suite/1,
	 init_per_testcase/2, end_per_testcase/2,
%	 code_CertificateChain_api/1,
%	 code_AttributeCertChain_api/1,
%	 code_VerifyingCertChain_api/1,
%	 code_AttributeCertificate_api/1,
%	 code_Certificate_api/1,
%	 code_TBSCertificate_api/1,
%	 code_CertificateSerialNumber_api/1,
%	 code_Version_api/1,
%	 code_AlgorithmIdentifier_api/1,
%	 code_Name_api/1,
%	 code_RDNSequence_api/1,
%	 code_RelativeDistinguishedName_api/1,
%	 code_AttributeTypeAndValue_api/1,
%	 code_Attribute_api/1,
%	 code_Validity_api/1,
%	 code_SubjectPublicKeyInfo_api/1,
%	 code_UniqueIdentifier_api/1,
%	 code_Extensions_api/1,
%	 code_Extension_api/1,
%	 code_AttributeCertificateInfo_api/1,
%	 code_AttCertVersion_api/1,
%	 code_Holder_api/1,
%	 code_AttCertIssuer_api/1,
%	 code_AttCertValidityPeriod_api/1,
%	 code_V2Form_api/1,
%	 code_IssuerSerial_api/1,
%	 code_ObjectDigestInfo_api/1,
%	 code_OpenSSL509_api/1,
	 ssl_server_peercert_api/1,
	 ssl_client_peercert_api/1]).


%%-----------------------------------------------------------------
%% Internal exports
%%-----------------------------------------------------------------
-export([fake_server_ORB/5]).

%%-----------------------------------------------------------------
%% Func: all/1
%% Args:
%% Returns:
%%-----------------------------------------------------------------
suite() -> [{ct_hooks,[ts_install_cth]}].

all() ->
    cases().

groups() ->
    [].

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, Config) ->
    Config.


%% NOTE - the fragment test cases must bu first since we explicitly set a request
%% id. Otherwise, the request-id counter would be increased and we cannot know
%% what it is.
cases() ->
    [ssl_server_peercert_api, ssl_client_peercert_api].

%%-----------------------------------------------------------------
%% Init and cleanup functions.
%%-----------------------------------------------------------------

init_per_testcase(_Case, Config) ->
    Path = code:which(?MODULE),
    code:add_pathz(filename:join(filename:dirname(Path), "idl_output")),
    Dog=test_server:timetrap(?default_timeout),
    orber:jump_start(0),
    oe_orber_test_server:oe_register(),
    [{watchdog, Dog}|Config].


end_per_testcase(_Case, Config) ->
    oe_orber_test_server:oe_unregister(),
    orber:jump_stop(),
    Path = code:which(?MODULE),
    code:del_path(filename:join(filename:dirname(Path), "idl_output")),
    Dog = ?config(watchdog, Config),
    test_server:timetrap_cancel(Dog),
    ok.

init_per_suite(Config) ->
    try crypto:start() of
        ok ->
	    case orber_test_lib:ssl_version() of
		no_ssl ->
		    {skip, "SSL is not installed!"};
		_ ->
		    Config
	    end
	catch _:_ ->
	    {skip, "Crypto did not start"}
    end.

end_per_suite(Config) ->
    application:stop(crypto),
    Config.

%%-----------------------------------------------------------------
%%  API tests for ORB to ORB, no security
%%-----------------------------------------------------------------


%%-----------------------------------------------------------------
%%  Encode and decode ASN.1 X509
%%-----------------------------------------------------------------

-ifdef(false).
%% OrberCSIv2
code_CertificateChain_api(doc) -> ["Code CertificateChain"];
code_CertificateChain_api(suite) -> [];
code_CertificateChain_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('CertificateChain', ?CertificateChain)),
    ?match({ok, [#'Certificate'{}]},
	   'OrberCSIv2':decode('CertificateChain', list_to_binary(Enc))),
    ok.

code_AttributeCertChain_api(doc) -> ["Code AttributeCertChain"];
code_AttributeCertChain_api(suite) -> [];
code_AttributeCertChain_api(_Config) ->
     {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('AttributeCertChain', ?AttributeCertChain)),
    ?match({ok, #'AttributeCertChain'{}},
	   'OrberCSIv2':decode('AttributeCertChain', list_to_binary(Enc))),
    ok.

code_VerifyingCertChain_api(doc) -> ["Code VerifyingCertChain"];
code_VerifyingCertChain_api(suite) -> [];
code_VerifyingCertChain_api(_Config) ->
     {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('VerifyingCertChain', ?VerifyingCertChain)),
    ?match({ok, [#'Certificate'{}]},
	   'OrberCSIv2':decode('VerifyingCertChain', list_to_binary(Enc))),
    ok.

%% PKIXAttributeCertificate
code_AttributeCertificate_api(doc) -> ["Code AttributeCertificate"];
code_AttributeCertificate_api(suite) -> [];
code_AttributeCertificate_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('AttributeCertificate', ?AttributeCertificate)),
    ?match({ok, #'AttributeCertificate'{}},
	   'OrberCSIv2':decode('AttributeCertificate', list_to_binary(Enc))),
    ok.

code_AttributeCertificateInfo_api(doc) -> ["Code AttributeCertificateInfo"];
code_AttributeCertificateInfo_api(suite) -> [];
code_AttributeCertificateInfo_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('AttributeCertificateInfo', ?AttributeCertificateInfo)),
    ?match({ok, #'AttributeCertificateInfo'{}},
	   'OrberCSIv2':decode('AttributeCertificateInfo', list_to_binary(Enc))),
    ok.

code_AttCertVersion_api(doc) -> ["Code AttCertVersion"];
code_AttCertVersion_api(suite) -> [];
code_AttCertVersion_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('AttCertVersion', ?AttCertVersion)),
    ?match({ok, ?AttCertVersion},
	   'OrberCSIv2':decode('AttCertVersion', list_to_binary(Enc))),
    ok.

code_Holder_api(doc) -> ["Code Holder"];
code_Holder_api(suite) -> [];
code_Holder_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('Holder', ?Holder)),
    ?match({ok, #'Holder'{}},
	   'OrberCSIv2':decode('Holder', list_to_binary(Enc))),
    ok.

code_AttCertIssuer_api(doc) -> ["Code AttCertIssuer"];
code_AttCertIssuer_api(suite) -> [];
code_AttCertIssuer_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('AttCertIssuer', ?AttCertIssuer)),
    ?match({ok, {v2Form, _}},
	   'OrberCSIv2':decode('AttCertIssuer', list_to_binary(Enc))),
    ok.

code_AttCertValidityPeriod_api(doc) -> ["Code AttCertValidityPeriod"];
code_AttCertValidityPeriod_api(suite) -> [];
code_AttCertValidityPeriod_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('AttCertValidityPeriod', ?AttCertValidityPeriod)),
    ?match({ok, #'AttCertValidityPeriod'{}},
	   'OrberCSIv2':decode('AttCertValidityPeriod', list_to_binary(Enc))),
    ok.

code_V2Form_api(doc) -> ["Code V2Form"];
code_V2Form_api(suite) -> [];
code_V2Form_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('V2Form', ?V2Form)),
    ?match({ok, #'V2Form'{}},
	   'OrberCSIv2':decode('V2Form', list_to_binary(Enc))),
    ok.

code_IssuerSerial_api(doc) -> ["Code IssuerSerial"];
code_IssuerSerial_api(suite) -> [];
code_IssuerSerial_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('IssuerSerial', ?IssuerSerial)),
    ?match({ok, #'IssuerSerial'{}},
	   'OrberCSIv2':decode('IssuerSerial', list_to_binary(Enc))),
    ok.

code_ObjectDigestInfo_api(doc) -> ["Code ObjectDigestInfo"];
code_ObjectDigestInfo_api(suite) -> [];
code_ObjectDigestInfo_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('ObjectDigestInfo', ?ObjectDigestInfo)),
    ?match({ok, #'ObjectDigestInfo'{}},
	   'OrberCSIv2':decode('ObjectDigestInfo', list_to_binary(Enc))),
    ok.

%% PKIX1Explicit88
code_Certificate_api(doc) -> ["Code Certificate"];
code_Certificate_api(suite) -> [];
code_Certificate_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('Certificate', ?Certificate)),
    ?match({ok, #'Certificate'{}},
	   'OrberCSIv2':decode('Certificate', list_to_binary(Enc))),
    ok.

code_TBSCertificate_api(doc) -> ["Code TBSCertificate"];
code_TBSCertificate_api(suite) -> [];
code_TBSCertificate_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('TBSCertificate', ?TBSCertificate)),
    ?match({ok, #'TBSCertificate'{}},
	   'OrberCSIv2':decode('TBSCertificate', list_to_binary(Enc))),
    ok.

code_CertificateSerialNumber_api(doc) -> ["Code CertificateSerialNumber"];
code_CertificateSerialNumber_api(suite) -> [];
code_CertificateSerialNumber_api(_Config) ->
    {ok, Enc} =
	?match({ok, _},
	       'OrberCSIv2':encode('CertificateSerialNumber', ?CertificateSerialNumber)),
    ?match({ok, ?CertificateSerialNumber},
	   'OrberCSIv2':decode('CertificateSerialNumber', list_to_binary(Enc))),
    ok.

code_Version_api(doc) -> ["Code Version"];
code_Version_api(suite) -> [];
code_Version_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('Version', ?Version)),
    ?match({ok, ?Version}, 'OrberCSIv2':decode('Version', list_to_binary(Enc))),
    ok.

code_AlgorithmIdentifier_api(doc) -> ["Code AlgorithmIdentifier"];
code_AlgorithmIdentifier_api(suite) -> [];
code_AlgorithmIdentifier_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('AlgorithmIdentifier', ?AlgorithmIdentifier)),
    ?match({ok, #'AlgorithmIdentifier'{}},
	   'OrberCSIv2':decode('AlgorithmIdentifier', list_to_binary(Enc))),
    ok.

code_Name_api(doc) -> ["Code Name"];
code_Name_api(suite) -> [];
code_Name_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('Name', ?Name)),
    ?match({ok, {rdnSequence,_}},
	   'OrberCSIv2':decode('Name', list_to_binary(Enc))),
    ok.

code_RDNSequence_api(doc) -> ["Code RDNSequence"];
code_RDNSequence_api(suite) -> [];
code_RDNSequence_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('RDNSequence', ?RDNSequence)),
    ?match({ok, [[#'AttributeTypeAndValue'{}]]},
	   'OrberCSIv2':decode('RDNSequence', list_to_binary(Enc))),
    ok.

code_RelativeDistinguishedName_api(doc) -> ["Code RelativeDistinguishedName"];
code_RelativeDistinguishedName_api(suite) -> [];
code_RelativeDistinguishedName_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('RelativeDistinguishedName', ?RelativeDistinguishedName)),
    ?match({ok, [#'AttributeTypeAndValue'{}]},
	   'OrberCSIv2':decode('RelativeDistinguishedName', list_to_binary(Enc))),
    ok.

code_AttributeTypeAndValue_api(doc) -> ["Code AttributeTypeAndValue"];
code_AttributeTypeAndValue_api(suite) -> [];
code_AttributeTypeAndValue_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('AttributeTypeAndValue', ?AttributeTypeAndValue)),
    ?match({ok, #'AttributeTypeAndValue'{}},
	   'OrberCSIv2':decode('AttributeTypeAndValue', list_to_binary(Enc))),
    ok.

code_Attribute_api(doc) -> ["Code Attribute"];
code_Attribute_api(suite) -> [];
code_Attribute_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('Attribute', ?Attribute)),
    ?match({ok, #'Attribute'{}},
	   'OrberCSIv2':decode('Attribute', list_to_binary(Enc))),
    ok.

code_Validity_api(doc) -> ["Code Validity"];
code_Validity_api(suite) -> [];
code_Validity_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('Validity', ?Validity)),
    ?match({ok, #'Validity'{}},
	   'OrberCSIv2':decode('Validity', list_to_binary(Enc))),
    ok.

code_SubjectPublicKeyInfo_api(doc) -> ["Code SubjectPublicKeyInfo"];
code_SubjectPublicKeyInfo_api(suite) -> [];
code_SubjectPublicKeyInfo_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('SubjectPublicKeyInfo', ?SubjectPublicKeyInfo)),
    ?match({ok, #'SubjectPublicKeyInfo'{}},
	   'OrberCSIv2':decode('SubjectPublicKeyInfo', list_to_binary(Enc))),
    ok.

code_UniqueIdentifier_api(doc) -> ["Code UniqueIdentifier"];
code_UniqueIdentifier_api(suite) -> [];
code_UniqueIdentifier_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('UniqueIdentifier', ?UniqueIdentifier)),
    ?match({ok, _}, 'OrberCSIv2':decode('UniqueIdentifier', list_to_binary(Enc))),
    ok.

code_Extensions_api(doc) -> ["Code Extensions"];
code_Extensions_api(suite) -> [];
code_Extensions_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('Extensions', ?Extensions)),
    ?match({ok, [#'Extension'{}]},
	   'OrberCSIv2':decode('Extensions', list_to_binary(Enc))),
    ok.

code_Extension_api(doc) -> ["Code Extension"];
code_Extension_api(suite) -> [];
code_Extension_api(_Config) ->
    {ok, Enc} =
	?match({ok, _}, 'OrberCSIv2':encode('Extension', ?Extension)),
    ?match({ok, #'Extension'{}},
	   'OrberCSIv2':decode('Extension', list_to_binary(Enc))),
    ok.

%% OpenSSL generated x509 Certificate
code_OpenSSL509_api(doc) -> ["Code OpenSSL generated x509 Certificate"];
code_OpenSSL509_api(suite) -> [];
code_OpenSSL509_api(_Config) ->
    {ok, Cert} =
	?match({ok, #'Certificate'{}},
	       'OrberCSIv2':decode('Certificate', ?X509DER)),
    AttrCertChain = #'AttributeCertChain'{attributeCert = ?AttributeCertificate,
					  certificateChain = [Cert]},
    {ok, EAttrCertChain} =
	?match({ok, _}, 'OrberCSIv2':encode('AttributeCertChain', AttrCertChain)),
    ?match({ok, #'AttributeCertChain'{}},
	   'OrberCSIv2':decode('AttributeCertChain', list_to_binary(EAttrCertChain))),
    ok.

-endif.

%%-----------------------------------------------------------------
%%  Test ssl:peercert
%%-----------------------------------------------------------------
ssl_server_peercert_api(doc) -> ["Test ssl:peercert (server side)"];
ssl_server_peercert_api(suite) -> [];
ssl_server_peercert_api(_Config) ->
    Options = orber_test_lib:get_options(iiop_ssl, server,
	2, [{iiop_ssl_port, 0}]),
    {ok, ServerNode, ServerHost} =
    ?match({ok,_,_}, orber_test_lib:js_node(Options)),
    ServerPort = orber_test_lib:remote_apply(ServerNode, orber, iiop_ssl_port, []),
    SSLOptions = orber_test_lib:get_options(ssl, client),
    {ok, Socket} =
    ?match({ok, _}, fake_client_ORB(ssl, ServerHost, ServerPort, SSLOptions)),
    {ok, _PeerCert} = ?match({ok, _}, orber_socket:peercert(ssl, Socket)),
    %% 	    ?match({ok, {rdnSequence, _}}, orber_socket:peercert(ssl, Socket, [pkix, subject])),
    %% 	    ?match({ok, {rdnSequence, _}}, orber_socket:peercert(ssl, Socket, [ssl, subject])),
    %	    ?match({ok, #'Certificate'{}},
    %		   'OrberCSIv2':decode('Certificate', PeerCert)),
    destroy_fake_ORB(ssl, Socket),
    ok.

ssl_client_peercert_api(doc) -> ["Test ssl:peercert (client side)"];
ssl_client_peercert_api(suite) -> [];
ssl_client_peercert_api(_Config) ->
    Options = orber_test_lib:get_options(iiop_ssl, client,
	2, [{iiop_ssl_port, 0}]),
    {ok, ClientNode, _ClientHost} =
    ?match({ok,_,_}, orber_test_lib:js_node(Options)),
    crypto:start(),
    ssl:start(),
    SSLOptions = orber_test_lib:get_options(ssl, server),
    {ok, LSock} = ?match({ok, _}, ssl:listen(0, SSLOptions)),
    {ok, {_Address, LPort}} = ?match({ok, {_, _}}, ssl:sockname(LSock)),
    IOR = ?match({'IOP_IOR',_,_},
	iop_ior:create_external({1, 2}, "IDL:FAKE:1.0",
	    "localhost", 6004, "FAKE",
	    [#'IOP_TaggedComponent'
		{tag=?TAG_SSL_SEC_TRANS,
		    component_data=#'SSLIOP_SSL'
		    {target_supports = 2,
			target_requires = 2,
			port = LPort}}])),
    spawn(orber_test_lib, remote_apply,
	[ClientNode, corba_object, non_existent, [IOR]]),
    {ok, Socket} = ?match({ok, _}, ssl:transport_accept(LSock)),
    ?match(ok, ssl:ssl_accept(Socket)),

    {ok, _PeerCert} = ?match({ok, _}, orber_socket:peercert(ssl, Socket)),
    %% 	    ?match({ok, {rdnSequence, _}}, orber_socket:peercert(ssl, Socket, [pkix, subject])),
    %% 	    ?match({ok, {rdnSequence, _}}, orber_socket:peercert(ssl, Socket, [ssl, subject])),
    %	    ?match({ok, #'Certificate'{}},
    %		   'OrberCSIv2':decode('Certificate', PeerCert)),
    ssl:close(Socket),
    ssl:close(LSock),
    ssl:stop(),
    ok.

%%-----------------------------------------------------------------
%% Local functions.
%%-----------------------------------------------------------------
-ifdef(false).
%% Not used yet.
context_test(Obj) ->
    IDToken1 = #'CSI_IdentityToken'{label = ?CSI_IdentityTokenType_ITTAbsent,
				    value = true},
    IDToken2 = #'CSI_IdentityToken'{label = ?CSI_IdentityTokenType_ITTAnonymous,
				    value = false},
    IDToken3 = #'CSI_IdentityToken'{label = ?CSI_IdentityTokenType_ITTPrincipalName,
				    value = [0,255]},
    IDToken4 = #'CSI_IdentityToken'{label = ?CSI_IdentityTokenType_ITTX509CertChain,
				    value = [1,255]},
    IDToken5 = #'CSI_IdentityToken'{label = ?CSI_IdentityTokenType_ITTDistinguishedName,
				    value = [2,255]},
    IDToken6 = #'CSI_IdentityToken'{label = ?ULONGMAX,
				    value = [3,255]},

    MTEstablishContext1 = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTEstablishContext,
       value = #'CSI_EstablishContext'{client_context_id = ?ULONGLONGMAX,
				       authorization_token =
				       [#'CSI_AuthorizationElement'
					{the_type = ?ULONGMAX,
					 the_element = [0,255]}],
				       identity_token = IDToken1,
				       client_authentication_token = [1, 255]}},
    MTEstablishContext2 = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTEstablishContext,
       value = #'CSI_EstablishContext'{client_context_id = ?ULONGLONGMAX,
				       authorization_token =
				       [#'CSI_AuthorizationElement'
					{the_type = ?ULONGMAX,
					 the_element = [0,255]}],
				       identity_token = IDToken2,
				       client_authentication_token = [1, 255]}},
    MTEstablishContext3 = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTEstablishContext,
       value = #'CSI_EstablishContext'{client_context_id = ?ULONGLONGMAX,
				       authorization_token =
				       [#'CSI_AuthorizationElement'
					{the_type = ?ULONGMAX,
					 the_element = [0,255]}],
				       identity_token = IDToken3,
				       client_authentication_token = [1, 255]}},
    MTEstablishContext4 = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTEstablishContext,
       value = #'CSI_EstablishContext'{client_context_id = ?ULONGLONGMAX,
				       authorization_token =
				       [#'CSI_AuthorizationElement'
					{the_type = ?ULONGMAX,
					 the_element = [0,255]}],
				       identity_token = IDToken4,
				       client_authentication_token = [1, 255]}},
    MTEstablishContext5 = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTEstablishContext,
       value = #'CSI_EstablishContext'{client_context_id = ?ULONGLONGMAX,
				       authorization_token =
				       [#'CSI_AuthorizationElement'
					{the_type = ?ULONGMAX,
					 the_element = [0,255]}],
				       identity_token = IDToken5,
				       client_authentication_token = [1, 255]}},
    MTEstablishContext6 = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTEstablishContext,
       value = #'CSI_EstablishContext'{client_context_id = ?ULONGLONGMAX,
				       authorization_token =
				       [#'CSI_AuthorizationElement'
					{the_type = ?ULONGMAX,
					 the_element = [0,255]}],
				       identity_token = IDToken6,
				       client_authentication_token = [1, 255]}},
    MTCompleteEstablishContext = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTCompleteEstablishContext,
       value = #'CSI_CompleteEstablishContext'{client_context_id = ?ULONGLONGMAX,
					       context_stateful = false,
					       final_context_token = [1, 255]}},
    MTContextError = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTContextError,
       value = #'CSI_ContextError'{client_context_id = ?ULONGLONGMAX,
				   major_status = 1,
				   minor_status = 2,
				   error_token = [2,255]}},
    MTMessageInContext = #'CSI_SASContextBody'
      {label = ?CSI_MsgType_MTMessageInContext,
       value = #'CSI_MessageInContext'{client_context_id = ?ULONGLONGMAX,
				       discard_context = true}},
    Ctx = [#'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTEstablishContext1},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTEstablishContext2},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTEstablishContext3},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTEstablishContext4},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTEstablishContext5},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTEstablishContext6},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTCompleteEstablishContext},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTContextError},
	   #'IOP_ServiceContext'{context_id=?IOP_SecurityAttributeService,
				 context_data = MTMessageInContext}],
    ?line ?match(ok, orber_test_server:testing_iiop_context(Obj, [{context, Ctx}])).


fake_server_ORB(Type, Port, Options) ->
    start_ssl(Type),
    {ok, ListenSocket, NewPort} =
	orber_socket:listen(Type, Port,
			    [{active, false}|Options]),
    Socket = orber_socket:accept(Type, ListenSocket),
    orber_socket:post_accept(Type, Socket),
    {ok, Socket, NewPort}.

-endif.

fake_server_ORB(Type, Port, Options, Action, Data) ->
    start_ssl(Type),
    {ok, ListenSocket, _NewPort} =
	orber_socket:listen(Type, Port, [{active, false}|Options]),
    Socket = orber_socket:accept(Type, ListenSocket),
    orber_socket:post_accept(Type, Socket),
    do_server_action(Type, Socket, Action, Data),
    orber_socket:close(Type, Socket),
    ok.

start_ssl(ssl) ->
    crypto:start(),
    ssl:start();
start_ssl(_) ->
    ok.


destroy_fake_ORB(ssl, Socket) ->
    orber_socket:close(ssl, Socket),
    ssl:stop();
destroy_fake_ORB(Type, Socket) ->
    orber_socket:close(Type, Socket).

fake_client_ORB(Type, Host, Port, Options) ->
    start_ssl(Type),
    Socket = orber_socket:connect(Type, Host, Port, [{active, false}|Options]),
    {ok, Socket}.

-ifdef(false).
%% Not used yet.

fake_client_ORB(Type, Host, Port, Options, Action, Data) ->
    start_ssl(Type),
    Socket = orber_socket:connect(Type, Host, Port, [{active, false}|Options]),
    Result = do_client_action(Type, Socket, Action, Data),
    orber_socket:close(Type, Socket),
    Result.

do_client_action(Type, Socket, fragments, FragList) ->
    ok = send_data(Type, Socket, FragList),
    {ok, Bytes} = gen_tcp:recv(Socket, 0),
    {#reply_header{request_id = ?REQUEST_ID, reply_status = no_exception}, ok, [Par]} =
	cdr_decode:dec_message({tk_void,[tk_any],[tk_any]}, Bytes),
    Par;
do_client_action(Type, Socket, fragments_max, FragList) ->
    ok = send_data(Type, Socket, FragList),
    {ok, Bytes} = gen_tcp:recv(Socket, 0),
    {#reply_header{request_id = ?REQUEST_ID, reply_status = system_exception}, Exc, []} =
	cdr_decode:dec_message({tk_void,[tk_any],[tk_any]}, Bytes),
    Exc;
do_client_action(Type, Socket, message_error, Data) ->
    ok = send_data(Type, Socket, Data),
    {ok,Bytes} = gen_tcp:recv(Socket, 0),
    'message_error' = cdr_decode:dec_message({tk_void,[tk_any],[tk_any]}, Bytes),
    ok;
do_client_action(_Type, _Socket, _Action, _Data) ->
    ok.

-endif.

do_server_action(Type, Socket, fragments, FragList) ->
    {ok, _B} = gen_tcp:recv(Socket, 0),
    ok = send_data(Type, Socket, FragList);
do_server_action(_Type, _Socket, _Action, _Data) ->
    ok.


send_data(_Type, _Socket, []) ->
    ok;
send_data(Type, Socket, [H|T]) ->
    orber_socket:write(Type, Socket, H),
    send_data(Type, Socket, T).

