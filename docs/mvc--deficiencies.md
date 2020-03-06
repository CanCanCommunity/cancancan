Hi all, First I like cancan because it collects all resource access rules in one place, but !

Although there are many benefits to mvc frameworks (mainly to large dev teams), there are of course short comings.

So, you have an app with user roles and define access to resources using cancan.  Then because of mvc you have to search all your views that render links to these protected resources. This creates a lot of unnecessary noise and is not very DRY. 

It seems to me that it would be simpler if the rules created in cancan automatically generated override filters (perhaps using deface) that warden could utilise so that these useless links are removed from the rendered html.

What do you think ?

I would call the approach mvc+ and define it such that the only legitimate use cases are those that have one requirement that has a common effect across all mvc domains (like user roles and access rights to resources).
 
I would love to create a solution but although I have 30 years as a self employed software engineer I am not fully up to speed with the rights and wrongs of the finer detail within the rails framework.

Any suggestions ! 
