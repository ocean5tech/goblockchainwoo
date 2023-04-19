package main

import (
	"fmt"
	"log"

	"github.com/ocean5tech/goblockchainwoo/wallet"
)

func init() {
	log.SetPrefix("Blockchain: ")
}

func main() {

	w := wallet.NewWallet()
	fmt.Println(w.PrivateKeyStr())
	fmt.Println(w.PublicKeyStr())
}
