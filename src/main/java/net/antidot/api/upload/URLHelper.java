package net.antidot.api.upload;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;

import net.antidot.api.common.Authentication;
import net.antidot.api.common.Scheme;
import net.antidot.api.common.Service;

import org.apache.http.client.utils.URIBuilder;

public class URLHelper {
    public static URI buildUri(Scheme scheme, String host,
            Authentication authentication, Service service, String pafName,
            String comment) throws URISyntaxException {
        return buildUri(scheme, host, authentication, service, pafName, comment, null);
    }

	public static URI buildUri(Scheme scheme, String host,
			Authentication authentication, Service service, String pafName,
			String comment, UploadType type) throws URISyntaxException {
		URIBuilder uriBuilder = new URIBuilder().setScheme(scheme.value())
				.setHost(host).setPath(buildPath(service, pafName))
				.setParameter("afs:login", buildAuthentication(authentication));
		if (comment != null) {
			uriBuilder.setParameter("comment", comment);
		}
        if (type != null) {
            uriBuilder.setParameter("afs:type", type.toString());
        }
		return uriBuilder.build();
	}

	private static String buildPath(Service service, String pafName) {
		return "/bo-ws/service/" + service.getId() + "/instance/"
				+ service.getStatus() + "/paf/" + pafName + "/upload";
	}

	private static String buildAuthentication(Authentication authentication) {
		return "login://" + encode(authentication.getUser()) + ":"
				+ encode(authentication.getPassword()) + "@"
				+ authentication.getAuthority();
	}

	private static String encode(String toEncode) {
		String tmp;
		try {
			tmp = URLEncoder.encode(toEncode, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException("UTF-8 not accepted!");
		}
		// URLEncode replaces spaces with '+' but we need %20 encoding !!!
		return tmp.replaceAll("\\+", "%20");
	}
}
