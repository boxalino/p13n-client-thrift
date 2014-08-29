namespace java com.boxalino.p13n.api.thrift
namespace php  com.boxalino.p13n.api.thrift

# Filter to be used in query. Note that type of generated filter depends on first non-null and non-empty value in order of preference. Values of lower priority are ignored:
# stringValues!=null && simpleValues.size()>0 => simple match, prefix!=null => prefix match, hierarchy!=null && hierarchy.size()>0 => hierarchy filter, else range filter    
struct Filter {
# whether the filter is negative (boolean NOT)  
  1: bool negative,
# field name to apply filter to
  2: string fieldName,
# values for simple match 
  3: list<string> stringValues,
# prefix match
  4: string prefix,
# hierarchy filter - when corresponding hierarchical field has encoded id  
  41: string hierarchyId,
# hierarchy filter - for example categories path in top-down order
  5: list<string> hierarchy,
# lower bound for range filter
  6: string rangeFrom,
# whether the lower bound is inclusive
  7: bool rangeFromInclusive,
# upper bound for range filter  
  8: string rangeTo,
# whether the upper bound is inclusive
  9: bool rangeToInclusive
}

# Used for date facets
enum DateRangeGap {
  SECOND = 1, 
  MINUTE = 2, 
  HOUR = 3, 
  DAY = 4, 
  WEEK = 5, 
  MONTH = 6, 
  YEAR = 7, 
  DECADE = 8, 
  CENTURY = 9
}

# Whether facets should be order by population descending or by collation
enum FacetSortOrder {
  POPULATION = 1,
  COLLATION = 2
}

struct FacetValue {
# corresponding value of the facet
  1: string stringValue,
# if range facets lower bound (inclusive)
  2: string rangeFromInclusive,
# if range facets lower bound (inclusive)  
  3: string rangeToExclusive,
# number of hits found
  4: i64 hitCount,
# id of hierarchy if corresponding field is hierarchical
  50: string hierarchyId,
# hierarchy if corresponding field is hierarchical
  60: list<string> hierarchy,
# whether the facet value has been selected in corresponding FacetRequest
  70: bool selected
}

struct FacetRequest {
# name of the field to get facet for
  1: string fieldName,
# whether the facet is numerical
  2: bool numerical,
# whether the facet is range facet
  3: bool range,
# maximum number of facets to return by given order, -1 for all of them
  4: i32 maxCount = -1,
# minimum facet population to return
  5: i32 minPopulation = 1,
# if the corresponding field is date then the gap to be used for facet
  6: DateRangeGap dateRangeGap,
# sort order
  7: FacetSortOrder sortOrder,
# whether the sort should be done ascending
  8: bool sortAscending,
# values selected from the facet.
# Note that results will be filtered by these values, but the corresponding 
# FacetResponse is as if this filter was not applied
  90: list<FacetValue> selectedValues,
# whether selectedValues should be considered in AND logic, 
# meaning filter out those that don't contain ALL selected 
# values - default is OR - include those contianing any of 
# selectedValue
  100: bool andSelectedValues = false
}

# field to be used for sorting 
struct SortField {
  1: string fieldName,
  2: bool reverse
}

struct SimpleSearchQuery {
# indexId to be used for search
  1: string indexId,
# language for localization
  2: string language,
# main search query
  3: string queryText,
# list of filters to apply
  4: list<Filter> filters,
# whether boolean OR should be aplied to the given list of filtes
# if false boolean AND will be applied
  5: bool orFilters,
# list of facets to be returned
  6: list<FacetRequest> facetRequests,
# optional list of sort fields for hardcoded sorting
# If not given, relevance sort order will be used
  7: list<SortField> sortFields,
# from which hit to return result
  8: i64 offset,
# how many hits to return
  9: i32 hitCount,
# which index fields to be returned 
 10: list<string> returnFields,
# field name of the field to do grouping by
 20: string groupBy,
# whether facets counts should contain number of groups
 30: bool groupFacets = true,
# how many hits in each group to return
 40: i32 groupItemsCount = 1,
# how to sort items within the group, default is score
 50: string groupItemsSort = "score",
# whether to sort items within the group ascending
 60: bool groupItemsSortAscending = false
}

struct ContextItem {
# id of the index to fetch context item data from
  1: string indexId,
# the field name of the item's unique identifier within the items index
# for example: 'sku' for items 'products' 
  2: string fieldName,
# actual item's identifier
# for example: actual sku of the product
  3: string contextItemId,
# role of the item within the context, used to address the item in the recommendation script.
# for example: 'main product' for recommendations within product detail page
  4: string role
}

struct ChoiceInquiry {
# personalization choice identificator 
  1: string choiceId,
# search query in a case of recommendation and search inquiries
  2: SimpleSearchQuery simpleSearchQuery,
# context items for recommendations 
  3: list<ContextItem> contextItems,
# minimal hit count to return for recommendations.
# if higher priority recommendation strategy yields less results, next strategy is tried  
  4: i32 minHitCount,
# set of variantIds to be excluded from result
  5: set<string> excludeVariantIds,
# 
  6: string scope = "system_rec",
  # 
  70: bool withRelaxation = false
}

struct RequestContext {
# parameters of request context. Usually - browser, platform, etc.
  1: map<string,list<string>> parameters
}

struct UserRecord {
# unique identifier of the customer
  1: string username
}

struct ChoiceRequest {
# 
  1: UserRecord userRecord,
# profile (visitor) identificator 
  2: string profileId,
# list of inquiries to be executed sequentially
# Inquiries with higher index may depend from those with lower index.
  3: list<ChoiceInquiry> inquiries,
# context of the request
  4: RequestContext requestContext
}

struct FacetResponse {
# name of the facet field
  1: string fieldName,
# list of facet values
  2: list<FacetValue> values
}

# item found
struct Hit {
# map containing name of the field and list of values as strings
# if index contains no value for a field, empty array will be returned.
  1: map<string, list<string>> values,
# index score of the hit
  2: double score,
# source scenarioId in case of mixed recommendations modes
 30: string scenarioId
}

# grouped item found
struct HitsGroup {
# value of the groupBy field
  10: string groupValue,
# total hits count within the group 
  20: i64 totalHitCount,
# group hits
  30: list<Hit> hits
}

struct SearchResult {
# list of hits found for given SimpleSearchQuery
  1: list<Hit> hits,
# list of requested facets or null if none requested
  2: list<FacetResponse> facetResponses,
# total number of hits
  3: i64 totalHitCount,
# relaxation query text for relaxation results or requested queryText for a regular SearchResult
  40: string queryText,
# grouped hits; not null when corresponding SimplSearchQuery has groupBy!=null 
  50: list<HitsGroup> hitsGroups
}

struct SearchRelaxation {
# 
  10: list<SearchResult> suggestionsResults,
# 
  20: list<SearchResult> subphrasesResults
}

struct Variant {
# id of the personalized variant
  1: string variantId,
# scenario identificator used to produce recommendation result or search result personalization
  2: string scenarioId,
# result of the search request for recommendations and search requests
  3: SearchResult searchResult,
# recommendation's result title localized in language requested in corresponding SimpleSearchQuery
  4: string searchResultTitle,
# When the service considers queryText invalid, it will evaluate and return relaxations 
# if it is requested in corresponding ChoiceInquiry and if relaxations could be found.
# Note that original query still could yield some results; it is up to the client to decide
# whether searchRelaxations should be used (with displaying appropriate message) or not.
  50: SearchRelaxation searchRelaxation
}

struct ChoiceResponse {
# list of personalized variants. Item's index corresponds to the index of the ChoiceInquiry
  1: list<Variant> variants
}

struct ProfilePropertyValue {
  1: string profileId,
  2: string propertyName,
  3: string propertyValue, 
  4: i32 confidence
}

struct BatchChoiceRequest {
  1: UserRecord userRecord,
# deprecated - use choiceInquiries instead.
# If choiceInquiries is given this field will be ignored 
  2: ChoiceInquiry choiceInquiry,
  3: RequestContext requestContext,
  4: list<string> profileIds,
# list of ChoiceInquiries to be executed sequentially.
# Note that list items can depend of items before in list 
  5: list<ChoiceInquiry> choiceInquiries
}

struct BatchChoiceResponse {
# deprecated - contains non-null value only if corresponding BatchChoiceRequest had only one ChoiceInquiry
  1: list<Variant> variants,
# outer list corresponds to profileIds given in BatchChoiceRequest, 
# while inner list corresponds to list of ChoiceInquiries from BatchChoiceRequest
  2: list<list<Variant>> selectedVariants
}

struct AutocompleteHit {
    11: string suggestion,
    21: string highlighted,
    31: SearchResult searchResult,
    41: double score
}

struct AutocompleteQuery {
    11: string indexId,
    21: string language,
    31: string queryText,
    41: i32 suggestionsHitCount,
    51: bool highlight,
    61: string highlightPre = "<em>",
    71: string highlightPost = "</em>"
}

struct AutocompleteRequest {
    11: UserRecord userRecord,
    21: string scope = "system_rec",
    31: string choiceId,
    41: string profileId,
    51: RequestContext requestContext,
    61: set<string> excludeVariantIds,
    71: AutocompleteQuery autocompleteQuery,
    81: string searchChoiceId,
    91: SimpleSearchQuery searchQuery
}

struct AutocompleteResponse {
    11: list<AutocompleteHit> hits,
    21: SearchResult prefixSearchResult
}

exception P13nServiceException {
  1: required string message
}

service P13nService {
  ChoiceResponse choose(ChoiceRequest choiceRequest) throws (1: P13nServiceException p13nServiceException),
  BatchChoiceResponse batchChoose(BatchChoiceRequest batchChoiceRequest) throws (1: P13nServiceException p13nServiceException),
  AutocompleteResponse autocomplete(AutocompleteRequest request) throws (1: P13nServiceException p13nServiceException)
}