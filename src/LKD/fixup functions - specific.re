
# archetype 12345
This function is called from the debug code whenever a problem in debug_object_\w+ is detected\..*?\nCalled from debug_object_.*? when the object [\s\S]*?\nThe function returns 1 when the fixup was successful, otherwise 0\. The return value is used to update the statistics\.

# diff 1234 from 12345
state is:\n[\s\S]*?•    ODEBUG_STATE_ACTIVE
# archetype 1234
This function is called from the debug code whenever a problem in debug_object_\w+ is detected\..*?\nCalled from debug_object_.*? when the object state is:\n[\s\S]*?•    ODEBUG_STATE_ACTIVE\nThe function returns 1 when the fixup was successful, otherwise 0\. The return value is used to update the statistics\.

# specific 12 from 1234
Note,? that the function needs to call the debug_object_\w+\(\) function again,? after the damage has been repaired in order to keep the state consistent\.
# archetype 12
This function is called from the debug code whenever a problem in debug_object_\w+ is detected\..*?\nCalled from debug_object_.*? when the object state is:\n[\s\S]*?•    ODEBUG_STATE_ACTIVE\nThe function returns 1 when the fixup was successful, otherwise 0\. The return value is used to update the statistics\.\nNote,? that the function needs to call the debug_object_\w+\(\) function again,? after the damage has been repaired in order to keep the state consistent\.

# specific 25 from 12345
The \w+ of statically initialized objects is a special case\. .*?The fixup function .*? this is a legitimate case of a statically initialized object or not\. In (this )?case .*? debug_object_init\(\) .*? to make the object known to the tracker.*? the function should return 0 because this is not a real fixup\.
# archetype 25
This function is called from the debug code whenever a problem in debug_object_\w+ is detected\..*?\nCalled from debug_object_.*? when the object [\s\S]*?\nThe function returns 1 when the fixup was successful, otherwise 0\. The return value is used to update the statistics\.\n.*?\nThe \w+ of statically initialized objects is a special case\. .*?The fixup function .*? this is a legitimate case of a statically initialized object or not\. In (this )?case .*? debug_object_init\(\) .*? to make the object known to the tracker.*? the function should return 0 because this is not a real fixup\.
