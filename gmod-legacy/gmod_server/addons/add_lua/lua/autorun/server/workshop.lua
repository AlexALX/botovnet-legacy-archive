/*This plugin adding workshop addons for users, so when they connect it will download itUsed on Botov-NET gmod server-----------MIT LicenseCopyright (c) 2015 by AlexALXPermission is hereby granted, free of charge, to any person obtaining a copyof this software and associated documentation files (the "Software"), to dealin the Software without restriction, including without limitation the rightsto use, copy, modify, merge, publish, distribute, sublicense, and/or sellcopies of the Software, and to permit persons to whom the Software isfurnished to do so, subject to the following conditions:The above copyright notice and this permission notice shall be included in allcopies or substantial portions of the Software.THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...*/local ids = {	--205607306,
	--199944580,
	106516163,
	187933083,}

for k,v in pairs(ids) do
	resource.AddWorkshop(v)
end