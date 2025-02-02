create proc sp_help
	@objname nvarchar(776) = NULL		-- object name we're after
as
	-- PRELIMINARY
	set nocount on
	declare	@dbname	sysname

	-- OBTAIN DISPLAY STRINGS FROM spt_values UP FRONT --
	declare @no varchar(35), @yes varchar(35), @none varchar(35)
	select @no = name from master.dbo.spt_values where type = 'B' and number = 0
	select @yes = name from master.dbo.spt_values where type = 'B' and number = 1
	select @none = name from master.dbo.spt_values where type = 'B' and number = 2

	-- If no @objname given, give a little info about all objects.
	if @objname is null
	begin
		-- DISPLAY ALL SYSOBJECTS --
        select
            'Name'          = o.name,
            'Owner'         = user_name(uid),
            'Object_type'   = substring(v.name,5,31)
        from sysobjects o, master.dbo.spt_values v
        where o.xtype = substring(v.name,1,2) collate database_default and v.type = 'O9T'
        order by Object_type desc, Name asc

		print ' '

		-- DISPLAY ALL USER TYPES
		select
			'User_type'		= name,
			'Storage_type'	= type_name(xtype),
			'Length'		= length,
			'Prec'			= TypeProperty(name, 'precision'),
			'Scale'			= TypeProperty(name, 'scale'),
			'Nullable'		= case when TypeProperty(name, 'AllowsNull') = 1
											then @yes else @no end,
			'Default_name'	= isnull(object_name(tdefault), @none),
			'Rule_name'		= isnull(object_name(domain), @none),
			'Collation'		= collation
		from systypes
		where xusertype > 256
		order by name

		return(0)
	end

	-- Make sure the @objname is local to the current database.
	select @dbname = parsename(@objname,3)

	if @dbname is not null and @dbname <> db_name()
		begin
			raiserror(15250,-1,-1)
			return(1)
		end

	-- @objname must be either sysobjects or systypes: first look in sysobjects
	declare @objid int
	declare @sysobj_type char(2)
	select @objid = id, @sysobj_type = xtype from sysobjects where id = object_id(@objname)

	-- IF NOT IN SYSOBJECTS, TRY SYSTYPES --
	if @objid is null
	begin
		-- UNDONE: SHOULD CHECK FOR AND DISALLOW MULTI-PART NAME
		select @objid = xusertype from systypes where name = @objname

		-- IF NOT IN SYSTYPES, GIVE UP
		if @objid is null
		begin
			select @dbname=db_name()
			raiserror(15009,-1,-1,@objname,@dbname)
			return(1)
		end

		-- DATA TYPE HELP (prec/scale only valid for numerics)
		select
			'Type_name'		= name,
			'Storage_type'	= type_name(xtype),
			'Length'		= length,
			'Prec'			= TypeProperty(name, 'precision'),
			'Scale'			= TypeProperty(name, 'scale'),
			'Nullable'		= case when allownulls=1 then @yes else @no end,
			'Default_name'	= isnull(object_name(tdefault), @none),
			'Rule_name'		= isnull(object_name(domain), @none),
			'Collation'		= collation
		from systypes
		where xusertype = @objid

		return(0)
	end

	-- FOUND IT IN SYSOBJECT, SO GIVE OBJECT INFO
	select
		'Name'				= o.name,
		'Owner'				= user_name(uid),
        'Type'              = substring(v.name,5,31),
		'Created_datetime'	= o.crdate
	from sysobjects o, master.dbo.spt_values v
	where o.id = @objid and o.xtype = substring(v.name,1,2) collate database_default and v.type = 'O9T'

	print ' '

	-- DISPLAY COLUMN IF TABLE / VIEW
	if @sysobj_type in ('S ','U ','V ','TF','IF')
	begin

		-- SET UP NUMERIC TYPES: THESE WILL HAVE NON-BLANK PREC/SCALE
		declare @numtypes nvarchar(80)
		select @numtypes = N'tinyint,smallint,decimal,int,real,money,float,numeric,smallmoney'

		-- INFO FOR EACH COLUMN
		print ' '
		select
			'Column_name'			= name,
			'Type'					= type_name(xusertype),
			'Computed'				= case when iscomputed = 0 then @no else @yes end,
			'Length'				= convert(int, length),
			'Prec'					= case when charindex(type_name(xtype), @numtypes) > 0
										then convert(char(5),ColumnProperty(id, name, 'precision'))
										else '     ' end,
			'Scale'					= case when charindex(type_name(xtype), @numtypes) > 0
										then convert(char(5),OdbcScale(xtype,xscale))
										else '     ' end,
			'Nullable'				= case when isnullable = 0 then @no else @yes end,
			'TrimTrailingBlanks'	= case ColumnProperty(@objid, name, 'UsesAnsiTrim')
										when 1 then @no
										when 0 then @yes
										else '(n/a)' end,
			'FixedLenNullInSource'	= case
						when type_name(xtype) not in ('varbinary','varchar','binary','char')
							Then '(n/a)'
						When status & 0x20 = 0 Then @no
						Else @yes END,
			'Collation'		= collation
		from syscolumns where id = @objid and number = 0 order by colid

		-- IDENTITY COLUMN?
		if @sysobj_type in ('S ','U ','V ','TF')
		begin
			print ' '
			declare @colname sysname
			select @colname = name from syscolumns where id = @objid
						and colstat & 1 = 1
			select
				'Identity'				= isnull(@colname,'No identity column defined.'),
				'Seed'					= ident_seed(@objname),
				'Increment'				= ident_incr(@objname),
				'Not For Replication'	= ColumnProperty(@objid, @colname, 'IsIDNotForRepl')
			-- ROWGUIDCOL?
			print ' '
			select @colname = null
			select @colname = name from syscolumns where id = @objid and number = 0
						and ColumnProperty(@objid, name, 'IsRowGuidCol') = 1
			select 'RowGuidCol' = isnull(@colname,'No rowguidcol column defined.')
		end
	end

	-- DISPLAY PROC PARAMS
	if @sysobj_type in ('P ') --RF too?
	begin
		-- ANY PARAMS FOR THIS PROC?
		if exists (select id from syscolumns where id = @objid)
		begin
			-- INFO ON PROC PARAMS
			print ' '
			select
				'Parameter_name'	= name,
				'Type'				= type_name(xusertype),
                'Length'			= length,
                'Prec'				= case when type_name(xtype) = 'uniqueidentifier' then xprec
										else OdbcPrec(xtype, length, xprec) end,
                'Scale'				= OdbcScale(xtype,xscale),
                'Param_order'		= colid,
				'Collation'		= collation

			from syscolumns where id = @objid
		end
	end

	-- DISPLAY TABLE INDEXES & CONSTRAINTS
	if @sysobj_type in ('S ','U ')
	begin
		print ' '
		execute sp_objectfilegroup @objid
		print ' '
		execute sp_helpindex @objname
		print ' '
		execute sp_helpconstraint @objname,'nomsg'
		if (select count(*) from sysdepends where depid = @objid and deptype = 1) = 0
		begin
			raiserror(15647,-1,-1) -- 'No views with schemabinding reference this table.'
		end
		else
		begin
            select distinct 'Table is referenced by views' = obj.name from sysobjects obj, sysdepends deps
				where obj.xtype ='V' and obj.id = deps.id and deps.depid = @objid
					and deps.deptype = 1 group by obj.name

		end
	end
	else if @sysobj_type in ('V ')
	begin
		-- VIEWS DONT HAVE CONSTRAINTS, BUT PRINT THESE MESSAGES BECAUSE 6.5 DID
		print ' '
		raiserror(15469,-1,-1) -- No constraints defined
		print ' '
		raiserror(15470,-1,-1) --'No foreign keys reference this table.'
		execute sp_helpindex @objname
	end

	return (0) -- sp_help

GO
