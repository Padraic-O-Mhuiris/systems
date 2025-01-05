# Berkeley Mono Package

The zip file is stored locally and in encrypted form through the following command:

```bash
gpg --encrypt --recipient 18F528675193C19214A73F1DEF4CEF1AF71A4EDD berkeley-mono.zip
```

Decrypting requires the recipient key as above:

```bash
gpg --decrypt berkeley-mono.zip.gpg > berkeley-mono.zip
```
