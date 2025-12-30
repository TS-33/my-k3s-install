使用命令：</br>
```shell
. <(cat ./k3s-init.sh)
```
初始化一个k3s master节点（会自动安装nerdctl和cni-plugins) </br>
注意需要节点能访问github，否则nerdctl会下载失败。 </br> </br>
脚本运行完成会生成worker_join.sh, 请拷贝到worker节点，然后在worker节点上执行：</br>
```shell
. <(cat ./worker_join.sh)
```
加入k3s集群。</br>
</br>
