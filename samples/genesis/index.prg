static cContent, cAction, nId, cUserName

//----------------------------------------------------------------------------//

function Main()

   Controller( AP_Args() )

return nil

//----------------------------------------------------------------------------//

function Controller( cRequest )

   local aRequest

   if ":" $ cRequest
      aRequest = hb_aTokens( cRequest, ":" )
      cRequest = aRequest[ 1 ]
      cAction  = aRequest[ 2 ]
      nId      = Val( aRequest[ 3 ] )
   endif    

   cContent = If( Empty( cRequest ), "users",;
       If( cRequest $ "menus,routes,database,settings,controllers,login", cRequest, "users" ) )

   do case   
      case AP_Method() == "GET"
         AP_RPuts( View( "default" ) )

      case AP_Method() == "POST"
         do case
            case cRequest == "login"
                 Login() 
         endcase 
   endcase   

return nil

//----------------------------------------------------------------------------//

function Login()

   local hPairs := AP_PostPairs()
    
   do case
      case hb_HHasKey( hPairs, "forgot" )
         AP_RPuts( View( "default" ) )
         if ! Empty( hPairs[ "username" ] ) 
            AP_RPuts( "<script>MsgInfo( 'An email has been sent to you to reset your password' )</script>" )
         else   
            AP_RPuts( "<script>MsgInfo( 'Please write your email or phone number' )</script>" )
         endif 
         
      case hb_HHasKey( hPairs, "continue" )     
           if Identify( hPairs[ "username" ], hPairs[ "password" ] )
              cContent = "welcome"
              AP_RPuts( View( "default" ) )
           else
              AP_RPuts( View( "default" ) )
              AP_RPuts( "<script>MsgInfo( 'wrong username or password', 'Please try it again' )</script>" )
           endif 
           
      case hb_HHasKey( hPairs, "ok" )
           AddUser( hPairs )
           AP_RPuts( View( "default" ) )
           AP_RPuts( "<script>MsgInfo( 'Please identify and press continue' )</script>" )
   endcase 

return nil

//----------------------------------------------------------------------------//

function AddUser( hPairs )

   USE ( hb_GetEnv( "PRGPATH" ) + "/data/users" ) SHARED
   
   APPEND BLANK
   if RLock()
      field->first    := hb_HGet( hPairs, "first" )
      field->last     := hb_HGet( hPairs, "last" )
      field->email    := hb_UrlDecode( hb_HGet( hPairs, "email" ) )
      field->phone    := hb_HGet( hPairs, "phone" )
      field->password := hb_Md5( hb_HGet( hPairs, "password" ) )
      DbUnLock()
   endif   
   USE
   
return nil   

//----------------------------------------------------------------------------//

function Identify( _cUserName, _cPassword )

   local lFound

   USE ( hb_GetEnv( "PRGPATH" ) + "/data/users" ) SHARED

   LOCATE FOR ( field->email = hb_UrlDecode( _cUserName ) .or. field->phone = _cUserName ) .and. ;
                field->password = hb_Md5( _cPassword )
   
   lFound = Found()
   
   if lFound
      cUserName = field->first
   endif   

   USE

return lFound

//----------------------------------------------------------------------------//

function GetContent()

return cContent

//----------------------------------------------------------------------------//

function GetAction()

return cAction   

//----------------------------------------------------------------------------//

function GetId()

return nId   

//----------------------------------------------------------------------------//

function UserName()

return cUserName

//----------------------------------------------------------------------------//

function MyEShopName()

return "My eshop"

//----------------------------------------------------------------------------//

function ItemStatus( cItem )

return If( cContent == cItem, "class='active'", "" ) 

//----------------------------------------------------------------------------//

function GetColor1() ; return "mediumblue"
function GetColor2() ; return "darkblue"
function GetColor3() ; return "rgb(34, 45, 50)"

//----------------------------------------------------------------------------//

function View( cView )

   local cViewName := hb_GetEnv( "PRGPATH" ) + "/views/" + cView + ".view" 
   local lFound := File( cViewName )
   local cData

   if lFound
      cData = MemoRead( cViewName )
    
      while ReplaceBlocks( @cData, "{{", "}}" )
      end
   else
      cData = "<h2>" + cViewName + " not found!</h2>" 
   endif    

return cData

//----------------------------------------------------------------------------//

function BuildBrowse( cTableName )

   local cHtml := "", n

   USE ( hb_GetEnv( "PRGPATH" ) + "/data/" + cTableName ) SHARED NEW

   cHtml += '<table id="browse" class="table table-striped table-hover;">' + CRLF
   cHtml += '<thead>' + CRLF
   cHtml += '<tr>' + CRLF
   cHtml += '<th scope="col">#</th>' + CRLF

   for n = 1 to FCount() 
      cHtml += '<th scope="col">' + FieldName( n ) + '</th>' + CRLF
   next

   cHtml += '<th scope="col">ACTIONS</th>' + CRLF

   cHtml += '</tr>' + CRLF
   cHtml += '</thead>' + CRLF
   cHtml += '<tbody>' + CRLF

   while ! Eof()
      cHtml += "<tr>" + CRLF
      cHtml += '<th scope="row">' + AllTrim( Str( RecNo() ) ) + "</th>" + CRLF
      
      for n = 1 to FCount()
         if ValType( FieldGet( n ) ) == "M"
            cHtml += '<td>' + SubStr( FieldGet( n ), 1, 20 ) + CRLF
            cHtml += '<button onclick="MsgInfo(' + "'" + FieldGet( n ) + "', '" + ;
                     FieldName( n ) + "');" + '"' + ;
                     'type="button" class="btn btn-primary"' + CRLF 
            cHtml += '   style="border-color:gray;color:gray;background-color:#f9f9f9;">' + CRLF
            cHtml += '   <span class="glyphicon glyphicon-eye-open" style="color:gray;padding-right:10px;">' + CRLF
            cHtml += '   </span>View</button>' +  "</td>" + CRLF            
         else   
            cHtml += '<td>' + ValToChar( FieldGet( n ) ) + "</td>" + CRLF
         endif   
      next

      cHtml += '<td>' + CRLF
      cHtml += '<button onclick="Edit(' + AllTrim( Str( RecNo() ) ) + ');"' + ;
               ' type="button" class="btn btn-primary"' + CRLF 
      cHtml += '   style="border-color:gray;color:gray;background-color:#f9f9f9;">' + CRLF
      cHtml += '   <span class="glyphicon glyphicon-edit" style="color:gray;padding-right:10px;">' + CRLF
      cHtml += '   </span>Edit</button>' + CRLF
      cHtml += '<button type="button" class="btn btn-primary"' + CRLF 
      cHtml += '   style="border-color:gray;color:gray;background-color:#f9f9f9;">' + CRLF
      cHtml += '   <span class="glyphicon glyphicon-trash" style="color:gray;padding-right:10px;">' + CRLF
      cHtml += '   </span>Delete</button>' + CRLF
      cHtml += '</td>' + CRLF

      SKIP
   end 

   cHtml += '</tbody>' + CRLF
   cHtml += '</table>' + CRLF

   USE

return cHtml   

//----------------------------------------------------------------------------//

function BuildEdit( cTableName )

   local cHtml := "", n

   USE ( hb_GetEnv( "PRGPATH" ) + "/data/" + cTableName ) SHARED NEW

   DbGoTo( GetId() )

   cHtml += '<table id="browse" class="table table-striped table-hover;">' + CRLF
   cHtml += '<thead>' + CRLF
   cHtml += '</thead>' + CRLF
 
   for n = 1 to FCount()
      cHtml += '<tr>'
      cHtml += '   <td class="center">' + FieldName( n ) + "</td>"
      cHtml += '   <td class="center"><input type="text" class="form-control" style="border-radius:0px"' + ;
                   " value='" + ValToChar( FieldGet( n ) ) + "'></td>"
      cHtml += '</tr>'
   next

   cHtml += '</table>' + CRLF

   USE

return cHtml

//----------------------------------------------------------------------------//

function hb_CapFirst( cText )

return Upper( Left( cText, 1 ) ) + SubStr( cText, 2 )   

//----------------------------------------------------------------------------//