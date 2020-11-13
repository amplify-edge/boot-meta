# boot-meta

meta data of things.

This is used to manage live things deployed.

Many projects have complicated systems for managing live deployments and tracking them.
Git is used to do that.

## why git ?

- Its a file system
- Its versioned and so a githash is all you need to distinguish the many deployments over time. Just include the githash into the deployed product.
- Its battle proven. Its git. all devs know how to use it.
- Its scalable, because followers can just keep up.
- Its immutable, and so adds by the CI, Release or live system can just create a new file and it all works. Like a WAL ( Write ahead log).
- The data can be read from any tools. The immutable files can be anything. For example a Protobuf, which itself is version independent. We use Protobuf heavily and so will use it here.
- Followers can catchup and then tools can parse the protobufs quickyl like a file sysem based DB.
- Followers can subscribe to changes via webhooks, if you dont want to them to subscribe via git pulls. This ensures the followers have no state if we dont want it.


## Functionality

- Project

	- a github org will over time have many projects.
	- use project as a top level folder to distinguish different projets.
	- suggest that the "repo name" and "subfolder" to the main.go is the natural pattern, because its self reflectable, so there is NO guessing and its toolale.
		- e.g main/maintemplatev2/server/main.go && main/maintemplatev2/cli/main.go

- authz

	- the data in meta can be encrpyted usign sops and age. 
	- devs, deployments can then have isolation if the need it.

- devs

	- devs need to be able to run the whole system with their config.
	- so a folder per env is possible.
		- Such as: Dev, Stage, Prod.
	- Dev can have sub folder for each developer. All they do is point to the right path bootstrap.go, and gitignore it.

- tool
	
	- our tools in general designed to talk to this and use its protobuf format for getting and setting data.
	- they just need to work off the right githash in go mod.

- gen

	- Can log to this if needed.

- config

	- Can get from this at runtme if needed. A central palce for config when you have many instances of servers.

- main

	- Can get from this for the config it needs.

- imports

	- Can ask meta for the modules it uses.
	- AT Compile Time it means one module know what version of another module its properly dependent on.
	- At Run Time, with a Module per Server pattern, cross dependent data can live here, with subscribe patterns

- CI 

	- Not sure yet... but i expect just the same as abive but in CI.

- releases

	- will update meta data when release happens, so live systems know.
	- a release ALWAYS embeds the githash it was built off ( of ALL its repos ) and stores that in meta so we can always go backwards.
	- a channel can latter be mapped to a release githash. Then we decide if we like a release channel to promote it by simle canging the githash that maps to a channel.

- binaries

	- from a binary, you can go backwards to know all the repos and their githashes used.
	- this data will be in meta data, and so when a binary is created, it will update the meta data.
	- these are currently different from releases, because binaries are packed and signed, and so have extra meta data with them, such as signed keys and lots of other bits.

	- where will binaries be ? 
		- Equinox maybe.
		- s3.
		- as long as the storage used is immmtuable then it will all work fine.
		- security on access to some part of the s3 needed ? those can be in meta and themselves be encrypted, with the key or passphrase given out of bounds to the callee that want to binary.

- provisioning

	- new server will need to be sshed into a pull a release via a curl. They can curl into meta to fidn out where the actual bianry lives.
	- existing server should auto update based on what channel it is on. Will look to github meta data to find out.
	- upgrades. Existing server will subscribe to meta for updates. Git does this for us for free.
	- rolling upgrades. Existing servers will follow whatver is in meta. We can easily model whatever pattern we want into the meta files. 
		- a "Captain" process running somewhere can have read / write / subscribe access to meta and do a command and control pattern to manage ti all. 

- feature flags
	
	- we will also probably need feature flags at some stage. 
	- Feasture flags map to channels and so the feature flags are stored as part of the config ( so need modify main config to hold feature flags data ).

- discovery

	- Servers can use git webhook subscriptions to know what to do based on the git meta data.
	- the githash of their release, is ALWAYS used by them. SO then many channels can use git as their meta data soruce and not confuse each other-

- meta data
	- all meta data that concerns the releases and provisioning will be modeled in git itself.
	- this will use afero and git.
	- this will act as a discovery server itself, with the NATS Server writing back to Git the changes, and other NATS and real servers getting web hooks from it.
	- this might sounds like etc reinvented, but a file system and git means you can easily control and fix things and not build up abstraction that kill your flexibility.
	- git hashes will map the code --> channels --> releaese --> binaries --> instances --> etc, etc
