# goblockchainwoo

1. 使用copy进行字符串到byte数组转换

```	
    pHashStr := "Genesis Block"
	var pHash [32]byte
	copy(pHash[:], []byte(pHashStr))
```

2.

```	
使用 GCM 作为 WSL Git 安装的凭据帮助程序意味着默认情况下，GCM 不遵循 WSL Git 中的任何配置集， (默认情况下) 。 
这是因为 GCM 作为 Windows 应用程序运行，因此将使用适用于 Windows 安装的 Git 来查询配置。 这意味着 GCM 的
代理设置等内容需要在 Git for Windows 和 WSL Git 中设置，因为它们存储在不同文件中 (%USERPROFILE%\.gitconfig 
与 \\wsl$\distro\home\$USER\.gitconfig) 。 可以配置 WSL，以便 GCM 将使用 WSL Git 配置，但这意味着代理设置
对于特定 WSL 安装是唯一的，不会与他人或 Windows 主机共享。
```	

3
func (bc *Blockchain) VerifyTransactionSignature(
	senderPublicKey *ecdsa.PublicKey, s *utils.Signature, t *Transaction) bool {
	m, _ := json.Marshal(t)
	h := sha256.Sum256([]byte(m))

	// return ecdsa.Verify(senderPublicKey, h[:], s.R, s.S)
	return ecdsa.VerifyASN1(senderPublicKey, h[:], []byte(s.String()))
}

"github.com/ocean5tech/goblockchainwoo/utils"

4.

声明一个Struct，所有属性都私有
声明一个NewFunc
声明属性的GetFunc
声明工具Func
