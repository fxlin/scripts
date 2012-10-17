#include <linux/module.h>
#include <linux/kernel.h>


int k = 0;

int __init init_module(void)
{
    int s;

    printk("a static var addr %p, a stack var addr %p", &k, &s);

    return 0;
}


void cleanup_module(void)
{
}
