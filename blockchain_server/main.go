// package main - blockchain_server的启动入口
package main

import (
	"flag"
	"log"
)

// Log前缀设定
func init() {
	log.SetPrefix("Blockchain: ")
}

func main() {
	port := flag.Uint("port", 5000, "TCP Port Number for Blockchain Server")
	flag.Parse()
	app := NewBlockchainServer(uint16(*port))
	app.Run()
}
