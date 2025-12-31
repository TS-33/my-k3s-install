仅适用于amd64 ubuntu 20.04及以上操作系统。
</br>
</br>
使用命令：</br>
```shell
source ./k3s_init.sh
```
初始化一个k3s master节点（会自动安装nerdctl、cni-plugins和buildkit) </br>
注意需要节点能访问github，否则nerdctl会下载失败。 </br> </br>
脚本运行完成会生成worker_join.sh, 请拷贝到worker节点，然后在worker节点上执行：</br>
```shell
source ./worker_join.sh
```
加入k3s集群。</br>
</br>

**k3s-module**文件夹下是k3s的组件安装</br>
注意第二个文件(即ippool)请根据自己网段的情况修改</br>
若有需要请按编号顺序执行，确保前一个文件下载的组件成功再执行下一个。
