package test

import (
	"log"
	"testing"

	"github.com/ocean5tech/goblockchainwoo/block"
	"github.com/ocean5tech/goblockchainwoo/utils"
	"github.com/stretchr/testify/assert"
)

// 1. log
// 2. console
// 3. gethost
// 4. wallet client A, B, C, D
// 5. wallet server wsA, wsB, wsC
// 6. blockserver: bs1, bs2, bs3, bs4
// test case
// case1: 命令行gethost，然后启动bs及ws, wsA-bs1， wsB-bs2, wsC-bs3, bs4
// case2: 四个浏览器窗口，分别访问三个ws，取得index.html及pubkey, privkey, adds, AD-wsA-bs1， B-wsB-bs2, C-wsC-bs3
// case3: A to B 1.0, B to C 2.5, C to D 4.5, D to A 2.4
// case4: 间隔30秒 ：Amount A B C D
// case5: / 来getchain
// case6: 间隔30秒 ：A to B 1.4, B to C 2.5, C to D 4.6, D to A 2.7
// case7: 间隔30秒 ：Amount A B C D

func TestBlockChain(t *testing.T) {
	hostIp := utils.GetHost()
	assert.NotEmpty(t, hostIp)

	startPort := block.BLOCKCHAIN_PORT_RANGE_START
	endPort := block.BLOCKCHAIN_PORT_RANGE_END
	for port := startPort; port <= endPort; port += 1 {
		log.Println(port)
	}
}
