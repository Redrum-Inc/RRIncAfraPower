# RRIncAfraPower

## Usage

### Start
```/loatheb start``` or ```/loatheb```

### Next (skip current healer)
```/loatheb next```

### Reset
```/loatheb reset```

This will be triggered automatically if combat log detects event `UNIT_DIED` with `destName`==`Loatheb`.

### History
`/rriap history`

Prints a log of all starts/resets and registered heals between. Can be cleared with:

`/rriap history clear`


## Options
Can be opened with ```/rrincafraprompt``` or ```/rriap```

![interface options](https://i.imgur.com/woVS8bG.png)
### Heal order
This is where you specify your heal order. It's very sensitive to typographical errors and you need to follow these rules:
* Case sensitive names.
* No spaces, only commas between each name.
* At least two names. (If you fail with this the value you entered will be replaced by "Dummy1,Dummy2".

### Raid warning
Posts the current healer in a raid warning each time the addon moves the queue forward.

### Skip dead or offline
If enabled the addon will check if the person who is next is alive, online and in the raid before announcing it's their turn. If they are not all of those things they will be skipped.

### Print heals
Prints all registered direct heals (SPELL_HEAL tag in combat logs) to your chat, will only be visible to you.

### Announce heal order
Will announce the heal order in raid chat when started.

