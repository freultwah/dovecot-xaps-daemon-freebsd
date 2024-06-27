--- pkg/apple_xserver_certs/http.go.orig	2024-06-27 10:02:55.801467000 +0300
+++ pkg/apple_xserver_certs/http.go	2024-06-27 10:04:20.279012000 +0300
@@ -1,11 +1,16 @@
 package apple_xserver_certs
 
 import (
+	"bufio"
 	"bytes"
+	"context"
+	"crypto/tls"
 	"encoding/pem"
+	"io"
 	"io/ioutil"
 	"log"
 	"net/http"
+	"time"
 )
 
 func NewCerts(username string, passwordhash string) *Certificates {
@@ -50,7 +55,6 @@
 }
 
 func sendRequest(reqBody []byte, newCerts bool) (respBody []byte) {
-	client := &http.Client{}
 	r := bytes.NewReader(reqBody)
 	url := "https://identity.apple.com/pushcert/caservice/renew"
 	if newCerts {
@@ -67,12 +71,51 @@
 	req.Header.Set("Accept", "*/*")
 	req.Header.Set("Accept-Language", "en-us")
 
-	resp, err := client.Do(req)
+	req.Close = true
+
+	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
+	defer cancel()
+
+	conn, err := new(tls.Dialer).DialContext(
+		ctx,
+		"tcp",
+		req.URL.Host+":443",
+	)
 	if err != nil {
-		log.Fatalln(err)
+		log.Fatalln(err) // TODO: Handle error properly
 	}
+	defer func() {
+		_ = conn.Close() //nolint:errcheck,gosec // Ignored on purpose
+	}()
 
-	defer resp.Body.Close()
+	if err := req.Write(conn); err != nil {
+		log.Fatalln(err) // TODO: Handle error properly
+	}
+
+	buf, err := io.ReadAll(io.LimitReader(conn, 9223372036854775807))
+	if err != nil {
+		log.Fatalln(err) // TODO: Handle error properly
+	}
+
+	const (
+		cr = "\r"
+		nl = "\n"
+	)
+	for _, ign := range []string{
+		"1;: mode=block",
+		"max-age=31536000;: includeSubdomains",
+	} {
+		buf = bytes.Replace(buf, []byte(nl+ign+cr+nl), []byte(nl), 1)
+	}
+
+	resp, err := http.ReadResponse(bufio.NewReader(bytes.NewReader(buf)), req)
+	if err != nil {
+		log.Fatalln(err) // TODO: Handle error properly
+	}
+	defer func() {
+		_ = resp.Body.Close() //nolint:errcheck,gosec // Ignored on purpose
+	}()
+
 	respBody, err = ioutil.ReadAll(resp.Body)
 	if err != nil {
 		log.Fatalln(err)
