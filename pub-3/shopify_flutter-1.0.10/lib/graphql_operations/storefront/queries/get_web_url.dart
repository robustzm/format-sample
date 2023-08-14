/// Query to get checkout web url
const String getWebUrl = r'''
 query($checkoutId: ID!){
  node(id: $checkoutId ) {
    ... on Checkout {
      id
      webUrl
    }
  }
}
''';
